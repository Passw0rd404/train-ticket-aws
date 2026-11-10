# tt-common (library chart)

Shared templates for every Train Ticket service: Deployment, Service, Secrets (MySQL + custom),
ConfigMaps, ServiceAccount, Ingress, HPA, PDB. All extras are optional.
All options: see `values.example.yaml`.

A service chart only needs one template file:

    {{ include "tt-common.all" . }}

Test (renders the example service):

    cd deployment/charts/tt-common/examples/consumer
    helm dependency update
    helm lint .
    helm template . | kubectl apply --dry-run=client -f -

Notes
- The Service/Deployment name is `name` (not prefixed with the release name), because services call each other by DNS name.
- Map values that are `false`, `0` or `""` do not override a global map entry (Helm merge behaviour). Do not set `enabled` flags in `global`.
