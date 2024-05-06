module "ecp-swp-swpeu-aks" {
  #for_each            = { for cluster in local.k8s_cfg.k8s : cluster.name_prefix => cluster }
  for_each            = { for cluster in local.k8s_cfg.k8s : cluster.product+cluster.name_prefix => cluster }
  source              = "../modules/aks-module"
  #environment         = each.value.environment 
  core_environment    = local.env_cfg.environment
  resource_group_name = "AKS-${local.k8s_cfg.location_label}-${local.env_cfg.environment}-${each.value.product}-K8S-RG"
  aks_cluster_name    = "AKS-${local.k8s_cfg.location_label}-${local.env_cfg.environment}-${each.value.product}-${each.value.name_prefix}"
  name_prefix         = each.value.name_prefix
  product             = each.value.product
  location            = local.k8s_cfg.location
  location_label      = local.k8s_cfg.location_label
  #aks_subnet_id                             = azurerm_subnet.aks-subnet.id
  vnet_rg_name     = local.k8s_cfg.vnet_rg_name
  vnet_name        = local.k8s_cfg.vnet_name
  route_table_name = local.k8s_cfg.route_table_name
  route_table_rg   = local.k8s_cfg.route_table_rg
  subnet_name      = each.value.subnet_name
  subnet_prefix    = each.value.subnet_prefix
  #aks_managed_identity_master_rg            = local.k8s_cfg.aks_managed_identity_master_rg

  dns_name = each.value.dns_name
  #############
  #privatednszone                            = each.value.privatednszone
  #privatednszone_rg                         = each.value.privatednszone_rg
  #########
  kubernetes_version                     = local.k8s_cfg.kubernetes_version
  sku_tier                               = each.value.sku_tier
  kubernetes_service_cidr                = each.value.service_cidr
  kubernetes_dns_service_ip              = each.value.dns_service_ip
  kubernetes_docker_bridge_cidr          = each.value.docker_bridge_cidr
  kubernetes_pod_cidr                    = each.value.pod_cidr
  node_resource_group                    = "AKS-${local.k8s_cfg.location_label}-${local.env_cfg.environment}-${each.value.product}-${each.value.name_prefix}-NODES"
  default_node_pool_name                 = each.value.node_pool_name
  default_node_pool_count                = each.value.node_pool_nodes_count
  default_node_pool_vm_size              = each.value.node_pool_vm_size
  deafult_node_pool_os_disk_size_gb      = each.value.node_pool_os_disk_size
  default_node_pool_type                 = each.value.node_pool_type
  default_node_pool_max_pods             = each.value.node_pool_max_pods
  default_node_pool_min_count            = each.value.nood_pool_min_count
  default_node_pool_max_count            = each.value.node_pool_max_count
  default_node_pool_auto_scaling_enabled = each.value.node_pool_auto_scaling_enabled
  ##############
  aks_managed_identity_kubelet_name = "AKS-${local.k8s_cfg.location_label}-${local.env_cfg.environment}-${each.value.product}-${each.value.name_prefix}-Kubenet-identity"
  aks_managed_identity_master_name  = "AKS-${local.k8s_cfg.location_label}-${local.env_cfg.environment}-${each.value.product}-${each.value.name_prefix}-master-identity"
  #############
  log_analytics_name          = "AKS-${local.k8s_cfg.location_label}-${local.env_cfg.environment}-${each.value.product}-${each.value.name_prefix}-laws"
  temporary_name_for_rotation = each.value.temporary_name_for_rotation
}

module "ecp-swp-swpeu-aks-node-pool" {
  for_each =  { for node_pools in local.k8s_cfg_node : node_pools.node_pool_name+node_pools.kubernetes_name => node_pools}
  source = "../modules/aks-node-pool" 
  resource_group_name                       = each.value.kubernetes_rg
  aks_cluster_name                          = each.value.kubernetes_name
  node_pool_name                            = each.value.node_pool_name
  node_pool_count                           = each.value.node_pool_nodes_count
  node_pool_vm_size                         = each.value.node_pool_vm_size
  node_pool_os_disk_size_gb                 = each.value.node_pool_os_disk_size
  node_pool_max_pods                        = each.value.node_pool_max_pods
  node_pool_min_count                       = each.value.nood_pool_min_count
  node_pool_max_count                       = each.value.node_pool_max_count
  node_pool_auto_scaling_enabled            = each.value.node_pool_auto_scaling_enabled
  node_pool_subnet                          = each.value.subnet_name
  node_pool_vnet_name                       = each.value.vnet_name
  node_pool_vnet_rg                         =  each.value.vnet_rg 
  node_pool_taints                          = each.value.node_taints
 depends_on                                 = [ module.ecp-swp-swpeu-aks ]
}