---
title: "Kubernetes - Edit Files in Containers"
date: 2024-07-13
tags:
  - Homelab
  - Kubernetes/General
---

# Kubernetes - Edit Files inside of Containers

This is a short post- documenting a few ways on how you can modify contents of files inside of a container's storage mounts.

<!-- more -->

## 1. Using `kubectl exec` with editors like `vi` or `nano`

The most straightforward way is to exec into the container and use a text editor.

```bash
kubectl exec -it -n <namespace> <pod_name> -- /bin/sh

# Once inside the container
vi /path/to/your/file
```

Replace `<namespace>` with your pod's namespace, `<pod_name>` with your pod's name, and `/path/to/your/file` with the file you want to edit.

## 2. Using `kubectl cp` to copy files

You can copy files between your local machine and the container using `kubectl cp`.

```bash
# Copy file from local to container
kubectl cp /local/path/to/file -n <namespace> <pod_name>:/container/path/to/file

# Copy file from container to local
kubectl cp -n <namespace> <pod_name>:/container/path/to/file /local/path/to/file
```

Replace `<namespace>` with your pod's namespace, `<pod_name>` with your pod's name, `/local/path/to/file` with the local file path, and `/container/path/to/file` with the container file path.

## 3. Browsing to the mount point on the Kubernetes host

If you know the mount point, you can access it directly on the Kubernetes host.

1. Locate the mount point:
   - Identify the node where the pod is running: `kubectl get pod <pod_name> -o wide`
   - SSH into the node: `ssh user@node_ip`
   - Find the mount point using: `findmnt | grep <pod_name>`

2. Edit the file on the mount point using a text editor.

## 4. Using a Side-Car Container with a Web-Based Editor

Update your existing deployment/statefulset/daemonset by adding a side-car container running `Filebrowser`. Use a random, non-common port to avoid conflicts with other containers in the pod. Also, mount the storage in the expected location by the Filebrowser container.

Add the following under the `containers` key and define the volume mounts:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: your-deployment
spec:
  replicas: 1
  selector:
    matchLabels:
      app: your-app
  template:
    metadata:
      labels:
        app: your-app
    spec:
      containers:
      # This is your EXISTING application.
      - name: your-app-container
        image: your-app-image
        volumeMounts:
        - mountPath: /data # Path in the app container
          name: shared-storage

      # This is the new filebrowser container you need to add.
      - name: filebrowser
        image: filebrowser/filebrowser
        ports:
        - containerPort: 8081       # Use a random, non-common port
          name: file-browser-http   # Descriptive name for the port
        # Update these volume mounts, to mount the pod's storage into this file browser plugin.
        volumeMounts:
        - mountPath: /srv # Path expected by Filebrowser
          name: shared-storage
      volumes:
      - name: shared-storage
        persistentVolumeClaim:
          claimName: your-pvc
```

### Option 1: Use `kubectl port-forward`

This method is ideal for temporary access to the Filebrowser.

Create a script to forward the port and echo the access URL:

```bash
#!/bin/bash

NAMESPACE=<namespace>
POD_NAME=<pod_name>
CONTAINER_PORT=8081 # This should match the containerPort defined in the deployment
FORWARD_PORT=8080 # The port to open on the host

HOST_IP=$(hostname -I | awk '{print $1}')
kubectl port-forward -n $NAMESPACE $POD_NAME $FORWARD_PORT:$CONTAINER_PORT --address 0.0.0.0 &
echo "Access Filebrowser at http://$HOST_IP:$FORWARD_PORT"
```

### Option 2: Create a Service and Ingress

This method is more permanent and suitable for regular access.

Create a service to expose the Filebrowser:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: filebrowser-service
  namespace: your-existing-namespace        # Set this to the namespace of your pod.
spec:
  selector:
    app: your-app                           # Change this to match the labels from your application.
  ports:
    - protocol: TCP
      port: 80          
      targetPort: file-browser-http         # We are referencing the file browser's port, by its name.
```

Create an ingress to access the Filebrowser:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: filebrowser-ingress
  namespace: your-existing-namespace        # Set this to the namespace of your pod.
spec:
  rules:
  - host: filebrowser.yourdomain.com        # Update this to your desired host you wish to access the file browser on.
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: filebrowser-service
            port:
              name: file-browser-http # Reference the port by its name
```

### Use-Cases

- **Option 1 (Port-Forwarding):** Ideal for temporary access during development or troubleshooting. The script sets up port forwarding and provides a URL for quick access.
- **Option 2 (Service and Ingress):** Suitable for more permanent access, allowing users to access the Filebrowser via a defined domain and service within the Kubernetes cluster.

## 5. If using NFS storage

Mount the NFS storage on another system and make changes directly.

```bash
# On another system
mount -t nfs <nfs_server>:/exported/path /mnt
vi /mnt/path/to/file
```

## 6. If using ISCSI

Stop the deployment or stateful set, then mount the ISCSI volume on another system.

1. Stop the deployment:
   ```bash
   kubectl scale deploy <deployment_name> --replicas=0
   ```

2. Mount the ISCSI volume on another system:
   ```bash
   iscsiadm -m discovery -t sendtargets -p <iscsi_target_ip>
   iscsiadm -m node --login
   mount /dev/<iscsi_device> /mnt
   vi /mnt/path/to/file
   ```