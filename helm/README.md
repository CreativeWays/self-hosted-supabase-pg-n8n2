# Supabase Helm Chart for K3s

This directory contains a full Helm chart to deploy a self-hosted Supabase with PostgreSQL v17 and pgvector to a local K3s cluster. It is based on the official docker-compose configuration.

## Overview

The chart sets up all Supabase components including:
- **PostgreSQL 17** (with pgvector) exposed on NodePort **5240**
- **Supabase Studio** (Dashboard) exposed on NodePort **5241** (via the Kong API Gateway)
- Kong, GoTrue (Auth), PostgREST, Realtime, Storage, ImgProxy, Postgres Meta, Edge Functions, and Supavisor

## Prerequisites

- A running K3s cluster.
- Helm 3 installed.
- OpenSSL (required for the secrets generation script).

## Installation Guide

### 1. Generate Configuration Secrets

Supabase requires various secrets (JWT keys, passwords, etc.). We've provided a script to auto-generate these and put them in a `custom-values.yaml` file to mimic the fields from `.env.example`.

Run the generation script:

```bash
cd helm/supabase
./generate-values.sh
```

This will create a `custom-values.yaml` file in your current directory containing your secure passwords and JWT tokens. Keep this file safe and out of version control!

### 2. Install the Helm Chart

You can now install the Supabase chart in your K3s cluster. We recommend using a dedicated namespace.

```bash
kubectl create namespace supabase
helm install supabase . -n supabase -f custom-values.yaml
```

### 3. Accessing the Services

Since we are using NodePorts, you can access the services using any of your K3s node IP addresses (or `localhost` if running locally).

- **Supabase Dashboard (Studio)**: Access the dashboard via Kong on **http://localhost:5241**
  - **Username:** `supabase`
  - **Password:** Retrieve the `dashboardPassword` from your `custom-values.yaml` file.
  
- **PostgreSQL Database**: Access the database directly on **localhost:5240**
  - **Username:** `postgres`
  - **Password:** Retrieve the `postgresPassword` from your `custom-values.yaml` file.
  - **Database:** `postgres`

### 4. Uninstalling

To uninstall/delete the Supabase deployment:

```bash
helm uninstall supabase -n supabase
```

Note that this will not delete the persistent volume claims. To completely clean up the storage, run:

```bash
kubectl delete pvc -l app.kubernetes.io/instance=supabase -n supabase
```
