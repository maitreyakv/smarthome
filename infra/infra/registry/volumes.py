from pulumi import ResourceOptions
from pulumi_kubernetes.core.v1 import (
    LocalVolumeSourceArgs,
    NodeSelectorArgs,
    NodeSelectorRequirementArgs,
    NodeSelectorTermArgs,
    PersistentVolume,
    PersistentVolumeClaim,
    PersistentVolumeClaimSpecArgs,
    PersistentVolumeSpecArgs,
    VolumeNodeAffinityArgs,
    VolumeResourceRequirementsArgs,
)
from pulumi_kubernetes.meta.v1 import ObjectMetaArgs

from ..shared import k8s_provider

pv = PersistentVolume(
    "pv",
    metadata=ObjectMetaArgs(name="registry-data"),
    spec=PersistentVolumeSpecArgs(
        capacity={"storage": "8Gi"},
        volume_mode="Filesystem",
        access_modes=["ReadWriteMany"],
        persistent_volume_reclaim_policy="Retain",
        storage_class_name="local-storage",
        local=LocalVolumeSourceArgs(path="/data/registry/"),
        node_affinity=VolumeNodeAffinityArgs(
            required=NodeSelectorArgs(
                node_selector_terms=[
                    NodeSelectorTermArgs(
                        match_expressions=[
                            NodeSelectorRequirementArgs(
                                key="kubernetes.io/hostname",
                                operator="In",
                                values=["raspberrypi"],
                            )
                        ]
                    )
                ]
            )
        ),
    ),
    opts=ResourceOptions(provider=k8s_provider),
)

pvc = PersistentVolumeClaim(
    "pvc",
    metadata=ObjectMetaArgs(name="registry-data-claim"),
    spec=PersistentVolumeClaimSpecArgs(
        access_modes=["ReadWriteMany"],
        resources=VolumeResourceRequirementsArgs(requests={"storage": "8Gi"}),
        storage_class_name="local-storage",
    ),
    opts=ResourceOptions(provider=k8s_provider, depends_on=[pv]),
)
