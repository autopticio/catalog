# 📖 Key Metrics for Prometheus Exporters
---

## Node Exporter

**Purpose**: Monitors operating system resources (CPU, memory, disk, network).

---

## cAdvisor

**Purpose**: Monitors Docker/Kubernetes containers (CPU, memory, network, disk usage).

---

## kube-state-metrics

**Purpose**: Exposes the state of Kubernetes resources (pods, deployments, nodes, etc.).

---

## Blackbox Exporter

**Purpose**: Tests the availability of services (HTTP, TCP, ICMP, etc.).

---

# Example Queries and Visualizations

---

### Node Exporter - Monitor CPU Usage by Mode (excluding idle)

This example measures the CPU usage rate by mode (`user`, `system`) over 24 hours. It filters out different modes and displays the results as stacked line charts.

```
// Node CPU Usage by Mode

where(@prometheus)
.what(
    "rate(node_cpu_seconds_total[10m])"
)
.when(24h)

// Get the data
.request($where[0];$what[0];$when[0]).as($cpu_usage)

// Filter by CPU mode
.filter($cpu_usage; "{mode='user'}").as($user)
.filter($cpu_usage; "{mode='system'}").as($system)

// Visualize
.note("### Node CPU Usage by Mode (excluding idle)")
.chart($user; @linestack)
.chart($system; @linestack)
```

---

### Blackbox Exporter (or General Process) - Monitor Resident Memory Usage

This example tracks the rate of resident memory usage (`process_resident_memory_bytes`) for processes over 24 hours, helping to detect memory growth or leaks.

```
// Resident Memory Usage Rate per Process

where(@prometheus)
.what(
    "rate(process_resident_memory_bytes[5m])"
)
.when(24h)

// Get the data
.request($where[0];$what[0];$when[0]).as($process_mem)

// Visualize
.note("### Resident Memory Usage Rate per Process Over Time")
.chart($process_mem; @linestack)
```

---
