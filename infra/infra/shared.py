from pathlib import Path

from pulumi_kubernetes import Provider

k8s_provider = Provider(
    "k8s-provider",
    kubeconfig=str(Path(__file__).parent / ".kube/config"),
)
