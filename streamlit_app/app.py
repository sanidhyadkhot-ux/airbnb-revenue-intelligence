
import pandas as pd
import numpy as np
import plotly.express as px
import streamlit as st
from pathlib import Path

st.set_page_config(page_title="Airbnb Revenue Intelligence", page_icon="🏠", layout="wide")
st.markdown("""
<style>
.block-container {padding-top: 1.5rem;}
.metric-card {background:#111827;border:1px solid #253046;border-radius:18px;padding:18px;}
</style>
""", unsafe_allow_html=True)

@st.cache_data
def load_data():
    path = Path(__file__).resolve().parents[1] / "data" / "processed" / "airbnb_wa_clean.csv"
    df = pd.read_csv(path)
    return df

df = load_data()
st.title("🏠 Airbnb Revenue Intelligence Platform")
st.caption("Western Australia Airbnb listings | SQL portfolio project upgraded with Streamlit analytics")

with st.sidebar:
    st.header("Filters")
    suburbs = sorted(df["neighbourhood_cleansed"].dropna().unique())
    selected_suburbs = st.multiselect("Suburb", suburbs, default=suburbs[:8])
    room_types = st.multiselect("Room type", sorted(df["room_type"].dropna().unique()), default=sorted(df["room_type"].dropna().unique()))
    max_price = int(np.nanpercentile(df["price_clean"], 95))
    price_range = st.slider("Price range", 0, max_price, (0, max_price))

f = df[df["room_type"].isin(room_types)]
if selected_suburbs:
    f = f[f["neighbourhood_cleansed"].isin(selected_suburbs)]
f = f[(f["price_clean"] >= price_range[0]) & (f["price_clean"] <= price_range[1])]

c1,c2,c3,c4,c5 = st.columns(5)
c1.metric("Total Listings", f"{len(f):,}")
c2.metric("Average Price", f"${f['price_clean'].mean():,.0f}")
c3.metric("Average Rating", f"{f['review_scores_rating'].mean():.2f}")
c4.metric("Superhost %", f"{f['host_is_superhost_flag'].mean()*100:.1f}%")
c5.metric("Revenue Proxy", f"${f['estimated_annual_revenue'].sum()/1e6:.1f}M")

st.divider()
left, right = st.columns([1.1, 1])
with left:
    suburb = f.groupby("neighbourhood_cleansed", as_index=False).agg(
        listings=("id","count"), avg_price=("price_clean","mean"), revenue=("estimated_annual_revenue","sum")
    ).sort_values("revenue", ascending=False).head(15)
    fig = px.bar(suburb, y="neighbourhood_cleansed", x="revenue", orientation="h", title="Top Suburbs by Estimated Annual Revenue")
    fig.update_layout(yaxis={"categoryorder":"total ascending"}, height=520)
    st.plotly_chart(fig, use_container_width=True)
with right:
    fig = px.scatter(f[f["price_clean"] < f["price_clean"].quantile(.98)], x="price_clean", y="review_scores_rating", color="room_type", size="number_of_reviews", hover_data=["neighbourhood_cleansed","name"], title="Price vs Rating Intelligence")
    fig.update_layout(height=520)
    st.plotly_chart(fig, use_container_width=True)

m1, m2 = st.columns([1,1])
with m1:
    map_df = f.dropna(subset=["latitude","longitude"])
    if len(map_df) > 0:
        fig = px.scatter_mapbox(map_df, lat="latitude", lon="longitude", color="price_clean", size="estimated_annual_revenue", hover_name="name", hover_data=["neighbourhood_cleansed","room_type","price_clean"], zoom=8, height=560, title="Location Intelligence Map")
        fig.update_layout(mapbox_style="open-street-map", margin={"r":0,"t":40,"l":0,"b":0})
        st.plotly_chart(fig, use_container_width=True)
with m2:
    st.subheader("Commercial Recommendations")
    top_suburb = suburb.iloc[0]["neighbourhood_cleansed"] if len(suburb) else "top suburb"
    st.write(f"**1. Prioritise {top_suburb}:** strongest revenue concentration in the filtered view.")
    st.write("**2. Use rating-led pricing:** listings rated 4.8+ can support premium pricing when availability suggests strong demand.")
    st.write("**3. Watch host concentration:** suburbs with many managed listings are more competitive and need differentiated positioning.")
    st.write("**4. Optimise availability:** high price + high availability listings may be overpriced or poorly positioned.")
    st.dataframe(suburb, use_container_width=True, hide_index=True)
