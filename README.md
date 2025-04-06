# Terraform Module for Monitored Kubernetes and Helm Deployment

This Terraform module provisions and configures a monitored Kubernetes environment with key resources such as namespaces, secrets, and Helm releases. It facilitates the installation and management of monitoring tools like **Grafana**, **Tempo**, **Loki**, and **Mimir**, alongside critical infrastructure like **Traefik**, **KubeVela**, and **Postgres Operator**. Additionally, it integrates S3-based storage for logs, metrics, and traces, enabling seamless observability in your cluster.

---

## **Features**

- Deploys and configures Kubernetes namespaces automatically.
- Installs and manages the following Helm-based resources:
  - **Monitoring Stack** (Loki, Tempo, Mimir, Grafana, Alloy)
    - Logs aggregation, metrics collection, distributed tracing, and visualization.
    - S3 storage integration for Tempo, Loki, and Mimir.
  - **Traefik**: An advanced Kubernetes ingress controller with TLS and autoscaling.
  - **KubeVela Core**: Application delivery platform with support for addon registries and custom workflows.
  - **Postgres Operator**: Manages PostgreSQL clusters in Kubernetes for backend storage systems.
- Configures Kubernetes secrets for GitHub Container Registry (GHCR) integration.
- Provides pre-defined namespace management with custom labels and annotations.
- Executes custom tasks through `null_resource` (`local-exec`) for enabling KubeVela addons and applying secure traits like ingress routes.
- Initializes KubeVela environments (`production`, `playground`, etc.) and applies custom application traits.
- Configures autoscaling, TLS, and persistence for core services.

---

## **Resources Created by the Module**

### **1. Helm Releases**

#### **Monitoring Stack**
- **Loki**: Log aggregation and querying system.
  - Dynamically configures S3 buckets for log storage, access credentials, and bucket policies.
  - Schema configurations for splitting queries and managing indexes.
- **Tempo**: Distributed tracing backend.
  - Configures S3 storage for traces with access credentials and endpoint management.
- **Mimir**: Metrics storage and management.
  - Supports multi-tenancy, S3-based block storage, and efficient query handling.
- **Grafana**: Visualization and alerting.
  - Connects to Loki, Tempo, and Mimir for logs, traces, and metrics visualization.
- **Alloy**: Enterprise insights plugin for Grafana.

#### **Traefik**
- HTTP(s) ingress controller with Let's Encrypt integration.
- Autoscaling enabled for high availability.
- Logs and API access enabled for debugging.

#### **KubeVela Core**
- Application delivery platform with support for experimental addons like FluxCD.
- Configures environments for production and playground deployments.

#### **Postgres Operator**
- Deploys and manages PostgreSQL clusters with replication enabled.

### **2. Kubernetes Namespaces**
- Creates namespaces based on the `local.namepaces` variable.
  - Example: `monitoring`, `production`, and `playground`.
- Labels and annotations are automatically attached.

### **3. Kubernetes Secrets**
- Configures Docker registry authentication secrets for GHCR.
  - Credentials: `ghcr_username`, `ghcr_password`, and `ghcr_email`.
- Secrets are created in all defined namespaces, ensuring applications can pull container images securely.

### **4. Null Resources**
Custom shell commands are executed using `null_resource` to enable advanced configurations for KubeVela and traits.

- Adds experimental addon registries.
- Enables FluxCD addon for KubeVela.
- Initializes KubeVela environments and applies traits for ingress routing and environmental configuration.

---

## **Usage**

### **Prerequisites**
- A Kubernetes cluster configured and accessible via `kubeconfig`.
- Terraform installed (version `>=1.5.0`).
- Knowledge of Helm chart values for customization.

### **Module Input Variables**

Here is the main input variables list:

| Name                      | Description                                   | Type     | Default                     |
| ------------------------- | --------------------------------------------- | -------- | --------------------------- |
| `kube_config_path`         | Path to kubeconfig file                      | `string` | None (required)             |
| `s3_endpoint`              | S3-compatible storage endpoint               | `string` | None (required)             |
| `s3_access_key_monitoring` | S3 access key for authentication             | `string` | None (required)             |
| `s3_secret_key_monitoring` | S3 secret key for authentication             | `string` | None (required)             |
| `s3_bucket_tempo`          | S3 bucket for Tempo                         | `string` | None (required)             |
| `s3_bucket_mimir`          | S3 bucket for Mimir                         | `string` | None (required)             |
| `s3_bucket_ruler_storage`  | S3 bucket for Mimir's ruler storage          | `string` | None (required)             |
| `s3_bucket_loki`           | S3 bucket for Loki data                     | `string` | None (required)             |
| `traefik_version`          | Traefik chart version                       | `string` | `33.0.0`                    |
| `kubevela_core_version`    | KubeVela core version                       | `string` | `1.10.0-alpha.1`            |
| `grafana_helm_chart_version`| Grafana chart version                      | `string` | `8.9.0`                     |
| `loki_helm_chart_version`  | Loki chart version                          | `string` | `6.25.1`                    |
| `alloy_helm_chart_version` | Alloy chart version                         | `string` | `0.11.0`                    |

### **Deployment Example**
#### Creating a `terraform.tfvars` File
```hcl
kube_config_path = "~/.kube/config"
s3_endpoint = "https://eu-central-1.linodeobjects.com"
s3_access_key_monitoring = "access_key"
s3_secret_key_monitoring = "secret_key"
s3_bucket_tempo = "tempo"
s3_bucket_mimir = "mimir"
s3_bucket_ruler_storage = "mimir-ruler"
s3_bucket_loki = "loki"
traefik_version = "33.0.0"
kubevela_core_version = "1.10.0-alpha.1"
grafana_helm_chart_version = "8.9.0"
loki_helm_chart_version = "6.25.1"
alloy_helm_chart_version = "0.11.0"
```

#### Deploying with Terraform
1. Clone the module repository:
   ```bash
   git clone https://github.com/<your-org-or-username>/monitoring-stack.git
   ```
2. Initialize Terraform:
   ```bash
   terraform init
   ```
3. Plan the deployment:
   ```bash
   terraform plan
   ```
4. Apply the changes to the cluster:
   ```bash
   terraform apply
   ```
5. Verify the deployment:
   ```bash
   kubectl get pods -n monitoring
   ```

---

## **Additional Features**

### **Observability**
The monitoring stack provides a comprehensive solution for observability:
- **Loki** for logs aggregation.
- **Tempo** for distributed tracing.
- **Mimir** for long-term metrics storage.
- **Grafana** for visualization.

### **Namespace Management**
Namespaces are dynamically created and labeled based on the `local.namepaces` list:
- Custom annotations and labels are added for better management.

### **KubeVela Integration**
KubeVela environments (`production` and `playground`) are initialized automatically, and custom traits (like ingress routes) are applied.

---

## **License**

This module is licensed under the MIT License. See the [LICENSE](https://github.com/<your-org-or-username>/monitoring-stack/blob/main/LICENSE) file for details.