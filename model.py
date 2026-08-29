import numpy as np
import pandas as pd
from db import load_data
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.model_selection import train_test_split

print("--- 1. Loading Route Data from MySQL View ---")
df_routes = load_data("SELECT * FROM vw_route_efficiency;")
print(f"Successfully loaded {len(df_routes)} shipment route records.\n")

# Display a statistical summary (great for your Statistics background!)
print("--- 2. Statistical Summary of Logistics Metrics ---")
print(
    df_routes[["shipping_cost", "distance_km", "weight_kg", "cost_per_km"]].describe()
)
print("\n")

print("--- 3. Training Scikit-Learn Cost Prediction Model ---")
# Drop any potential missing rows
df_model = df_routes[["distance_km", "weight_kg", "shipping_cost"]].dropna()

# Define independent features (X) and target variable (y)
X = df_model[["distance_km", "weight_kg"]]
y = df_model["shipping_cost"]

# Split into 80% Training and 20% Testing sets
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)

# Initialize and train Linear Regression
model = LinearRegression()
model.fit(X_train, y_train)

# Evaluate model accuracy on unseen test data
y_pred = model.predict(X_test)
r2 = r2_score(y_test, y_pred)
rmse = np.sqrt(mean_squared_error(y_test, y_pred))

print(f"Model R² Score (Accuracy): {r2:.4f}")
print(f"Root Mean Squared Error (RMSE): KES {rmse:.2f}")
print(
    f"Learned Impact -> Distance Coefficient: {model.coef_[0]:.2f} per km | Weight Coefficient: {model.coef_[1]:.2f} per kg"
)