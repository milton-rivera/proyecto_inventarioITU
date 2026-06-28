#!/bin/bash
echo "🏗️ Desplegando capa de persistencia (MongoDB)..."
kubectl apply -f ../databases/ -n inventario-itu

echo "⏳ Esperando estabilización de servicios de bases de datos..."
sleep 5

echo "⚙️ Desplegando lógica de negocio (Backend)..."
kubectl apply -f ../backend/ -n inventario-itu

echo "🌐 Desplegando interfaz de usuario (Frontend)..."
kubectl apply -f ../frontend/ -n inventario-itu

echo "🛡️ Blindando el clúster con políticas de red Zero Trust..."
kubectl apply -f ../network-policies/ -n inventario-itu

echo "✅ Proceso completado. Estado actual del clúster:"
kubectl get all -n inventario-itu
