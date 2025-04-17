

```markdown
# 🧰 Running a Local 3-Node Kafka Cluster (Pre-4.0 with Zookeeper)

This guide walks you through setting up a local 3-node Apache Kafka cluster (prior to version 4.0) using Zookeeper. Each Kafka broker runs on a different port and writes its own logs to a separate directory for easy tracking.

---

## 🗂️ Step 1: Create Log Directories

Create temporary directories for log data for each Kafka node:

```bash
mkdir -p tmp/kafka-logs-1
mkdir -p tmp/kafka-logs-2
mkdir -p tmp/kafka-logs-3
```

---

## 📝 Step 2: Create Separate Configuration Files

Copy the default `server.properties` to create 3 unique configurations:

```bash
cp config/server.properties config/server-1.properties
cp config/server.properties config/server-2.properties
cp config/server.properties config/server-3.properties
```

---

## ⚙️ Step 3: Modify Configuration Files

### `config/server-1.properties`

```properties
broker.id=1
log.dirs=tmp/kafka-logs-1
listeners=PLAINTEXT://localhost:9092
```

### `config/server-2.properties`

```properties
broker.id=2
log.dirs=tmp/kafka-logs-2
listeners=PLAINTEXT://localhost:9093
```

### `config/server-3.properties`

```properties
broker.id=3
log.dirs=tmp/kafka-logs-3
listeners=PLAINTEXT://localhost:9094
```

---

## 🧠 Conceptual Overview

Each **Kafka broker (or node)** is essentially an **individual application** that can be:

- 🖥️ Running on a **separate physical machine**
- 🐳 Running inside **containers or Kubernetes pods**
- 🌐 Running on **different ports** on the same machine

These brokers together form a **Kafka Cluster** where:
- A broker acts as the **leader** for some partitions
- Others act as **followers**
- They handle **replication**, **fault tolerance**, and **load distribution**

---

## ✅ Concept Summary

> A **Kafka Cluster** = A group of **Kafka Brokers** working together  
> Each broker can run:
> - On a **separate machine**
> - In a **separate container/pod**
> - Or on a **different port** on the same machine

---

## 🖼️ ASCII Diagram: Zookeeper-based Kafka Cluster (Pre-4.0)

```plaintext
                        Kafka Cluster
                    +-------------------+
                    |                   |
                    |    Zookeeper      |  ⟵ coordinates the brokers
                    |                   |
                    +---------+---------+
                              |
        +---------------------+---------------------+
        |                     |                     |
+---------------+   +----------------+   +----------------+
| Kafka Broker 1|   | Kafka Broker 2 |   | Kafka Broker 3 |
|  Port: 9092   |   |  Port: 9093    |   |  Port: 9094    |
|  Log Dir: ... |   |  Log Dir: ...  |   |  Log Dir: ...  |
+---------------+   +----------------+   +----------------+
        |                     |                     |
        +---------+-----------+-----------+---------+
                  |                       |
             Producers               Consumers
           (send messages)        (read messages)
```

---

## ⚡ Kafka 4.0 and KRaft Mode

From Kafka **v4.0 onwards**, **Zookeeper is removed**. Kafka uses **KRaft (Kafka Raft Metadata mode)**, where metadata is stored and replicated within the Kafka brokers themselves.

### 🖼️ Kafka 4.0 Cluster (KRaft Mode)

```plaintext
                      Kafka 4.0 Cluster (KRaft Mode)
                    +-------------------------------+
                    |        Controller Quorum      |
                    |   (Raft metadata management)   |
                    +---------------+---------------+
                                    |
         +--------------------------+--------------------------+
         |                          |                          |
+----------------+       +----------------+         +----------------+
| Kafka Broker 1 |       | Kafka Broker 2 |         | Kafka Broker 3 |
|  Port: 9092    |       |  Port: 9093    |         |  Port: 9094    |
|  Role: Leader  |       |  Role: Follower|         |  Role: Follower|
+----------------+       +----------------+         +----------------+
|                        |                          |
+-----------+------------+------------+-------------+
|                         |
Producers                Consumers
(send messages)         (read messages)
```

---

## 🚀 Starting the Cluster (Zookeeper-Based)

Once configs are ready, start each Kafka broker in separate terminals:

```bash
bin/kafka-server-start.sh config/server-1.properties
bin/kafka-server-start.sh config/server-2.properties
bin/kafka-server-start.sh config/server-3.properties
```

---

## 🛠️ Using Makefile for Setup (Optional)

You can use the provided `Makefile` to automate this setup:

```bash
make setup-zk     # Sets up directories and config files
make start-zk     # Starts the 3-node Kafka cluster
```

---

## 📚 Further Reading

- [Kafka Docs](https://kafka.apache.org/documentation/)
- [KRaft Overview](https://kafka.apache.org/documentation/#kraft)


## Creating Kafka topics
```
bin/kafka-topics.sh --create \
--topic my-topic \
--bootstrap-server localhost:9092 \
--replication-factor 1 \   # should not be greater than number of brokers
--partitions 3

```

```
bin/kafka-topics.sh --create \
  --topic my-topic \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3


```

## Describing Kafka topics
```
bin/kafka-topics.sh --describe \
--bootstrap-server localhost:9092 \
--topic my-topic2
```

## Sending the message Below command starts interactive shell
````
bin/kafka-console-producer.sh --topic users --bootstrap-server localhost:9092

````
## Runs Zookeeper interactive shell

````
bin/zookeeper-shell.sh localhost:2181
ls / list everything for zookeeper in the directory

ls /brokers/ids

get /controller  (gives all controllers)


````