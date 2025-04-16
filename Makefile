# Customize these
KAFKA_HOME := $(CURDIR)
LOG_DIR := $(KAFKA_HOME)/tmp
CONFIG_DIR := $(KAFKA_HOME)/config
BIN_DIR := $(KAFKA_HOME)/bin
CLUSTER_ID := $(shell $(BIN_DIR)/kafka-storage.sh random-uuid)

.PHONY: all zk setup-zk start-zk setup-kraft format-kraft start-kraft clean

all: help

help:
	@echo "Makefile for Kafka 3-node cluster (Zookeeper or KRaft)"
	@echo "Available targets:"
	@echo "  setup-zk     - Set up config and logs for Zookeeper-based cluster"
	@echo "  start-zk     - Start 3 Kafka brokers using Zookeeper configs"
	@echo "  setup-kraft  - Set up config and logs for Kafka 4.x KRaft mode"
	@echo "  format-kraft - Format KRaft storage directories (run once)"
	@echo "  start-kraft  - Start 3 Kafka brokers in KRaft mode"
	@echo "  clean        - Delete log dirs and configs"

#######################################
# Zookeeper-based (prior to Kafka 4.0)
#######################################
setup-zk:
	@echo "Creating log directories for Zookeeper-based cluster..."
	mkdir -p $(LOG_DIR)/kafka-logs-1
	mkdir -p $(LOG_DIR)/kafka-logs-2
	mkdir -p $(LOG_DIR)/kafka-logs-3

	@echo "Copying and modifying config files..."
	cp $(CONFIG_DIR)/server.properties $(CONFIG_DIR)/server-1.properties
	cp $(CONFIG_DIR)/server.properties $(CONFIG_DIR)/server-2.properties
	cp $(CONFIG_DIR)/server.properties $(CONFIG_DIR)/server-3.properties

	sed -i '' 's|^broker.id=.*|broker.id=1|' $(CONFIG_DIR)/server-1.properties
	sed -i '' 's|^log.dirs=.*|log.dirs=$(LOG_DIR)/kafka-logs-1|' $(CONFIG_DIR)/server-1.properties
	echo "listeners=PLAINTEXT://localhost:9092" >> $(CONFIG_DIR)/server-1.properties

	sed -i '' 's|^broker.id=.*|broker.id=2|' $(CONFIG_DIR)/server-2.properties
	sed -i '' 's|^log.dirs=.*|log.dirs=$(LOG_DIR)/kafka-logs-2|' $(CONFIG_DIR)/server-2.properties
	echo "listeners=PLAINTEXT://localhost:9093" >> $(CONFIG_DIR)/server-2.properties

	sed -i '' 's|^broker.id=.*|broker.id=3|' $(CONFIG_DIR)/server-3.properties
	sed -i '' 's|^log.dirs=.*|log.dirs=$(LOG_DIR)/kafka-logs-3|' $(CONFIG_DIR)/server-3.properties
	echo "listeners=PLAINTEXT://localhost:9094" >> $(CONFIG_DIR)/server-3.properties

start-zk: start-zookeeper
	@echo "Starting Kafka brokers using Zookeeper..."
	$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/server-1.properties &
	$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/server-2.properties &
	$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/server-3.properties &

start-zookeeper:
	  bin/zookeeper-server-start.sh config/zookeeper.properties


start-zk-1:
		$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/server-1.properties

start-zk-2:
		$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/server-2.properties

start-zk-3:
		$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/server-3.properties
#######################################
# Kafka 4.x KRaft mode
#######################################
setup-kraft:
	@echo "Creating log directories for KRaft cluster..."
	mkdir -p $(LOG_DIR)/kafka-logs-1
	mkdir -p $(LOG_DIR)/kafka-logs-2
	mkdir -p $(LOG_DIR)/kafka-logs-3

	@echo "Creating KRaft config files..."
	cp $(CONFIG_DIR)/kraft/server.properties $(CONFIG_DIR)/kraft-broker-1.properties
	cp $(CONFIG_DIR)/kraft/server.properties $(CONFIG_DIR)/kraft-broker-2.properties
	cp $(CONFIG_DIR)/kraft/server.properties $(CONFIG_DIR)/kraft-broker-3.properties

	sed -i '' 's|^node.id=.*|node.id=1|' $(CONFIG_DIR)/kraft-broker-1.properties
	sed -i '' 's|^log.dirs=.*|log.dirs=$(LOG_DIR)/kafka-logs-1|' $(CONFIG_DIR)/kraft-broker-1.properties
	sed -i '' 's|^listeners=.*|listeners=PLAINTEXT://localhost:9092|' $(CONFIG_DIR)/kraft-broker-1.properties
	echo "controller.quorum.voters=1@localhost:9092,2@localhost:9093,3@localhost:9094" >> $(CONFIG_DIR)/kraft-broker-1.properties
	echo "process.roles=broker,controller" >> $(CONFIG_DIR)/kraft-broker-1.properties

	sed -i '' 's|^node.id=.*|node.id=2|' $(CONFIG_DIR)/kraft-broker-2.properties
	sed -i '' 's|^log.dirs=.*|log.dirs=$(LOG_DIR)/kafka-logs-2|' $(CONFIG_DIR)/kraft-broker-2.properties
	sed -i '' 's|^listeners=.*|listeners=PLAINTEXT://localhost:9093|' $(CONFIG_DIR)/kraft-broker-2.properties
	echo "controller.quorum.voters=1@localhost:9092,2@localhost:9093,3@localhost:9094" >> $(CONFIG_DIR)/kraft-broker-2.properties
	echo "process.roles=broker,controller" >> $(CONFIG_DIR)/kraft-broker-2.properties

	sed -i '' 's|^node.id=.*|node.id=3|' $(CONFIG_DIR)/kraft-broker-3.properties
	sed -i '' 's|^log.dirs=.*|log.dirs=$(LOG_DIR)/kafka-logs-3|' $(CONFIG_DIR)/kraft-broker-3.properties
	sed -i '' 's|^listeners=.*|listeners=PLAINTEXT://localhost:9094|' $(CONFIG_DIR)/kraft-broker-3.properties
	echo "controller.quorum.voters=1@localhost:9092,2@localhost:9093,3@localhost:9094" >> $(CONFIG_DIR)/kraft-broker-3.properties
	echo "process.roles=broker,controller" >> $(CONFIG_DIR)/kraft-broker-3.properties

format-kraft:
	@echo "Formatting Kafka KRaft storage directories with cluster ID: $(CLUSTER_ID)"
	$(BIN_DIR)/kafka-storage.sh format -t $(CLUSTER_ID) -c $(CONFIG_DIR)/kraft-broker-1.properties
	$(BIN_DIR)/kafka-storage.sh format -t $(CLUSTER_ID) -c $(CONFIG_DIR)/kraft-broker-2.properties
	$(BIN_DIR)/kafka-storage.sh format -t $(CLUSTER_ID) -c $(CONFIG_DIR)/kraft-broker-3.properties

start-kraft:
	@echo "Starting Kafka brokers in KRaft mode..."
	$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/kraft-broker-1.properties &
	$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/kraft-broker-2.properties &
	$(BIN_DIR)/kafka-server-start.sh $(CONFIG_DIR)/kraft-broker-3.properties &

clean:
	rm -rf $(LOG_DIR)/kafka-logs-*
	rm -f $(CONFIG_DIR)/server-1.properties
	rm -f $(CONFIG_DIR)/server-2.properties
	rm -f $(CONFIG_DIR)/server-3.properties
	rm -f $(CONFIG_DIR)/kraft-broker-*.properties
