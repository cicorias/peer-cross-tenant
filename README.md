

#### login via:
```bash
az login --allow-no-subscriptions --tenant $demo_tenant_id
az login --allow-no-subscriptions --tenant $demo_tenant_id2

az account set -s $demo_subscription_id

#you should see two subs via az cli with the Primary subscription/tenant set as Default.
az account list -o table --all --query "[].{TenantID: tenantId, Subscription: name, Default: isDefault, ID: id}"
```