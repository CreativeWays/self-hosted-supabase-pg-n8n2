# Standalone Supabase Postgres for Kubernetes

This directory contains a complete, standalone Kubernetes configuration for deploying the Supabase Postgres instance (v17.6.1.136) complete with pgvector and all necessary Supabase initialization scripts.

## Contents

The `postgres.yaml` file defines the following resources:
- **Secret (`supabase-db-secrets`)**: Contains your passwords and JWT keys.
- **ConfigMap (`supabase-db-init`)**: Contains the initialization SQL scripts necessary to set up internal Supabase schemas, roles, Realtime configurations, webhooks extensions, and pooler support.
- **StatefulSet (`supabase-db`)**: Manages the Postgres deployment and provisions a `10Gi` Persistent Volume.
- **Service (`supabase-db`)**: Internal ClusterIP service exposing port 5432.
- **Service (`supabase-db-external`)**: NodePort service exposing Postgres externally on port **5240**.

## Deployment Instructions

### 1. Configure Secrets

Before deploying, you should review and update the secrets in `postgres.yaml`. Look for the `Secret` section at the top of the file:

```yaml
stringData:
  # CHANGE THESE VALUES BEFORE DEPLOYING IN PRODUCTION
  postgres-password: "your-super-secret-postgres-password"
  jwt-secret: "your-super-secret-jwt-token-with-at-least-32-characters-long"
```

Update `postgres-password` and `jwt-secret` with secure, hard-to-guess strings. Ensure the JWT secret is at least 32 characters long.

### 2. Deploy to Kubernetes

Deploy the file to your cluster using `kubectl`:

```bash
kubectl apply -f postgres.yaml
```

If you wish to deploy it to a specific namespace (e.g. `database`), you can run:
```bash
kubectl apply -f postgres.yaml -n database
```

### 3. Verify Deployment

Check if the StatefulSet is running:

```bash
kubectl get pods -l app.kubernetes.io/name=supabase-db
```

Watch the logs to ensure initialization is successful:

```bash
kubectl logs -f statefulset/supabase-db
```

### 4. Connect to Postgres

Once running, you can connect to your database:

**From inside the cluster:**
```
postgres://postgres:your-super-secret-postgres-password@supabase-db:5432/postgres
```

**From outside the cluster:**
Connect using your Kubernetes Node IP and the configured NodePort (`5240`):
```
postgres://postgres:your-super-secret-postgres-password@<NODE_IP>:5240/postgres
```
