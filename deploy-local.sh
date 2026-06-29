#!/bin/bash
set -e

echo "🚀 Iniciando despliegue local en Minikube para Inventario ITU..."

# 1. Apuntar al entorno Docker de Minikube
echo "📦 Configurando entorno Docker de Minikube..."
eval $(minikube docker-env)

# 2. Construir imágenes inmutables
echo "🔨 Construyendo imagen del Backend (JBoss WildFly)..."
docker build -t fuanis-inventario-backend:v1 ./backend

echo "🔨 Construyendo imagen del Frontend (Nginx)..."
docker build -t fuanis-inventario-frontend:v1 ./frontend

# 3. Aplicar Namespace
echo "🌐 Creando Namespace..."
kubectl apply -f k8s/namespace/inventario-namespace.yaml

# 4. Desplegar Base de Datos (MongoDB)
echo "🍃 Desplegando MongoDB..."
kubectl apply -f k8s/databases/mongo-pvc.yaml
kubectl apply -f k8s/databases/mongo-service.yaml
kubectl apply -f k8s/databases/mongo-deployment.yaml

# 5. Desplegar Backend (ConfigMap, Secrets, Service, Deployment)
echo "⚙️ Desplegando Backend..."
kubectl apply -f k8s/backend/configmap.yaml
kubectl apply -f k8s/backend/secrets.yaml
kubectl apply -f k8s/backend/service.yaml
kubectl apply -f k8s/backend/deployment.yaml

# 6. Desplegar Frontend (Service, Deployment)
echo "🖥️ Desplegando Frontend..."
kubectl apply -f k8s/frontend/service.yaml
kubectl apply -f k8s/frontend/deployment.yaml

# 7. Aplicar Políticas de Red (Zero Trust)
echo "🔒 Aplicando Políticas de Red..."
kubectl apply -f k8s/network-policies/allow-dns.yaml
kubectl apply -f k8s/network-policies/politicas-red.yaml

echo "✅ Despliegue completado con éxito. Ejecuta 'kubectl get pods -n inventario-itu' para ver el estado."
