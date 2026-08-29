import io
import openpyxl
import pandas as pd
import pydeck as pdk
from db import load_data
from sklearn.linear_model import LinearRegression
import streamlit as st

# Page Configuration
st.set_page_config(
    page_title="Supply Chain Optimizer & Map Hub", page_icon="🌍", layout="wide"
)

st.title("🌍 Executive Supply Chain Intelligence & Geospatial Hub")
st.markdown(
    "Real-time MySQL analytics, predictive ML cost modeling, interactive route maps, and report generation."
)

# Load data from MySQL views via db.py
try:
    df_monthly = load_data("SELECT * FROM vw_monthly_summary;")
    df_carriers = load_data("SELECT * FROM vw_carrier_performance;")
    df_routes = load_data("SELECT * FROM vw_route_efficiency;")
except Exception as e:
    st.error(f"Error loading data from database: {e}")
    st.stop()

# --- Section 1: Top KPI Summary Metrics ---
total_spend = df_monthly["total_monthly_spend"].sum()
total_shipments = df_monthly["total_shipments"].sum()
avg_cost_per_km = df_routes["cost_per_km"].mean()

col1, col2, col3 = st.columns(3)
with col1:
    st.metric(label="Total Logistics Spend", value=f"KES {total_spend:,.2f}")
with col2:
    st.metric(label="Total Tracked Shipments", value=f"{total_shipments:,}")
with col3:
    st.metric(label="Avg Cost per Kilometer", value=f"KES {avg_cost_per_km:,.2f}")

st.divider()

# --- Section 2: Geospatial Map Visualization ---
st.subheader("🗺️ Regional Logistics Hub & Route Map")
st.markdown(
    "Visualizing distribution nodes across East African transport corridors."
)

# Coordinate mapping for regional cities
city_coords = {
    "Nairobi": {"lat": -1.2921, "lon": 36.8219},
    "Mombasa": {"lat": -4.0435, "lon": 39.6682},
    "Kampala": {"lat": 0.3476, "lon": 32.5825},
    "Kigali": {"lat": -1.9441, "lon": 30.0619},
    "Dar es Salaam": {"lat": -6.7924, "lon": 39.2083},
    "Eldoret": {"lat": 0.5143, "lon": 35.2698},
}

# Attach coordinates to route data safely using Pandas fillna
map_data = df_routes.copy()
map_data["origin_lat"] = (
    map_data["origin_city"]
    .map(lambda x: city_coords.get(x, {}).get("lat"))
    .fillna(-1.29)
)
map_data["origin_lon"] = (
    map_data["origin_city"]
    .map(lambda x: city_coords.get(x, {}).get("lon"))
    .fillna(36.82)
)
map_data["dest_lat"] = (
    map_data["destination_city"]
    .map(lambda x: city_coords.get(x, {}).get("lat"))
    .fillna(0.34)
)
map_data["dest_lon"] = (
    map_data["destination_city"]
    .map(lambda x: city_coords.get(x, {}).get("lon"))
    .fillna(32.58)
)

# Render PyDeck Arc Layer for shipments
layer = pdk.Layer(
    "ArcLayer",
    data=map_data,
    get_source_position=["origin_lon", "origin_lat"],
    get_target_position=["dest_lon", "dest_lat"],
    get_source_color=[0, 128, 255, 160],
    get_target_color=[255, 0, 128, 160],
    get_width=3,
    pickable=True,
)

# Set initial view centered around East Africa
view_state = pdk.ViewState(
    latitude=-1.0, longitude=35.0, zoom=5.5, pitch=30, bearing=0
)

st.pydeck_chart(
    pdk.Deck(
        layers=[layer],
        initial_view_state=view_state,
        tooltip={
            "html": "<b>Route:</b> {origin_city} ➔ {destination_city}<br/><b>Cost:</b> KES {shipping_cost}",
            "style": {"backgroundColor": "steelblue", "color": "white"},
        },
    )
)

st.divider()

# --- Section 3: Machine Learning Cost Predictor Widget ---
st.subheader("🤖 Predictive Shipping Cost Estimator (Scikit-Learn)")
df_model = df_routes[["distance_km", "weight_kg", "shipping_cost"]].dropna()
X = df_model[["distance_km", "weight_kg"]]
y = df_model["shipping_cost"]

ml_model = LinearRegression()
ml_model.fit(X, y)

col_input1, col_input2 = st.columns(2)
with col_input1:
    input_distance = st.slider(
        "Distance (Kilometers)",
        min_value=100.0,
        max_value=5000.0,
        value=1000.0,
        step=50.0,
    )
with col_input2:
    input_weight = st.slider(
        "Cargo Weight (Kilograms)",
        min_value=50.0,
        max_value=3000.0,
        value=500.0,
        step=25.0,
    )

predicted_cost = ml_model.predict([[input_distance, input_weight]])[0]
st.success(
    f"Estimated Shipping Cost for **{input_distance:,.0f} km** and **{input_weight:,.0f} kg**: **KES {predicted_cost:,.2f}**"
)

st.divider()

# --- Section 4: Automated Excel Report Export ---
st.subheader("📥 Executive Report Export")
st.markdown(
    "Download a formatted, multi-tab Excel workbook containing live summary metrics and route efficiencies."
)


def create_excel_report():
    output = io.BytesIO()
    with pd.ExcelWriter(output, engine="openpyxl") as writer:
        df_monthly.to_excel(writer, sheet_name="Monthly Summary", index=False)
        df_carriers.to_excel(
            writer, sheet_name="Carrier Performance", index=False
        )
        df_routes.to_excel(writer, sheet_name="Route Efficiency", index=False)
    return output.getvalue()


excel_data = create_excel_report()

st.download_button(
    label="📊 Download Complete Excel Report (.xlsx)",
    data=excel_data,
    file_name="Supply_Chain_Executive_Report.xlsx",
    mime="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
)

st.divider()

# --- Section 5: Data Explorer Table ---
st.subheader("🔍 Complete Route Efficiency Data Explorer")
st.dataframe(df_routes, use_container_width=True)