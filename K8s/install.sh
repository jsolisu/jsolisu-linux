#!/bin/bash
sudo apt-get install -y kubeadm kubelet kubectl
kubeadm version && kubelet --version && kubectl version