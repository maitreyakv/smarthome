from pulumi import ResourceOptions
from pulumi_kubernetes.apps.v1 import Deployment, DeploymentSpecArgs
from pulumi_kubernetes.core.v1 import (
    ContainerArgs,
    PersistentVolumeClaimVolumeSourceArgs,
    PodSpecArgs,
    PodTemplateSpecArgs,
    Service,
    ServicePortArgs,
    ServiceSpecArgs,
    ServiceSpecType,
    VolumeArgs,
    VolumeMountArgs,
)
from pulumi_kubernetes.meta.v1 import LabelSelectorArgs, ObjectMetaArgs

from ..shared import k8s_provider
from .volumes import pv, pvc

registry = Deployment(
    "registry",
    metadata=ObjectMetaArgs(
        name="registry",
        labels={"app": "registry"},
    ),
    spec=DeploymentSpecArgs(
        replicas=1,
        selector=LabelSelectorArgs(match_labels={"app": "registry"}),
        template=PodTemplateSpecArgs(
            metadata=ObjectMetaArgs(labels={"app": "registry"}),
            spec=PodSpecArgs(
                containers=[
                    ContainerArgs(
                        name="registry",
                        image="registry:latest",
                        volume_mounts=[
                            VolumeMountArgs(
                                name=pv.metadata["name"],
                                mount_path="/var/lib/registry",
                            )
                        ],
                    )
                ],
                volumes=[
                    VolumeArgs(
                        name=pv.metadata["name"],
                        persistent_volume_claim=PersistentVolumeClaimVolumeSourceArgs(
                            claim_name=pvc.metadata["name"]
                        ),
                    )
                ],
            ),
        ),
    ),
    opts=ResourceOptions(provider=k8s_provider),
)

Service(
    "registry-service",
    metadata=ObjectMetaArgs(name="registry", labels={"app": "registry"}),
    spec=ServiceSpecArgs(
        type=ServiceSpecType.NODE_PORT,
        ports=[
            ServicePortArgs(
                port=5000,
                target_port=5000,
                node_port=32000,
            )
        ],
        selector={"app": "registry"},
    ),
    opts=ResourceOptions(provider=k8s_provider, depends_on=[registry]),
)
