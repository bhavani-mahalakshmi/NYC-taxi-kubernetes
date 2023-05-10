**Problem Statement**

You will be creating a highly scalable and highly available data processing pipeline that takes a document stream as its input and performs various processing operations on it before streaming it into a distributed neo4j setup to allow for near real-time processing and analytics.

This document has been designed to explore the pipeline one connection at a time. It is important to understand the motivation of every component as a unit and in tandem. The project document will guide you along the way while also encouraging self-exploration.

**Step 0: The Network Whisperer (0 pts)**

The most important part of this project is to understand how data is going to flow from Point A to Point B. This section will answer that question, and white everything may not be obvious on the very first glance, as every step passes, information given over here will start to gain value and help you along the way.

![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.002.png)

**Step 1: Order in the Chaos (20 pts)**

In this step, you will set up the orchestrator and Kafka for your pipeline. The orchestrator is a tool that helps you manage the different components of your pipeline, such as data ingestion, processing, and storage. You will use **minikube** as your orchestrator, which is a lightweight Kubernetes implementation that runs locally on your machine. Kafka is a distributed streaming platform that helps you collect and process the incoming data streams. You will use Kafka to ingest data from the document stream and distribute it to other components of your pipeline. The following diagram shows what all should be set up by the end of this step.

![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.003.png)

**Hints:**

- The most important part of any project is to understand the environment and set it up. Thats what you should aim to do first, install minikube, understand what it is. Once you start to get familiar with it, you need to understand what deployment and services in kubernetes are. The grading environment already has minikube and helm installed and present in thePATH for your convenience. We have also provided a file (grading-info.md) that![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.004.png) shows the commands used by the grading environment.
- After you have Minikube installed and ready to go, we move to creating a Kafka deployment inside of Minikube. The first step Kafka is to set up Zookeeper that is essential for the operation for Kafka.
- We have provided you with **2 YAML** files, zookeper-setup.yaml andkafka-setup.yaml, ![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.005.png)both these files are partially complete. The zookeper-setup.yaml containing information to create a deployment and the kafka-setup.yaml containing information to create a service. You need to complete both of these files, adding deployment information to one and adding service information to the other.
- You **must** use the following configurations at least:
- Use theconfluentinc/cp-kafka:7.3.3 image![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.006.png)
- KAFKA\_BROKER\_ID should be "**1**"
- KAFKA\_ZOOKEEPER\_CONNECT should be "zookeeper-service:2181"
- KAFKA\_LISTENER\_SECURITY\_PROTOCOL\_MAP should be PLAINTEXT:PLAINTEXT,PLAINTEXT\_INTERNAL:PLAINTEXT
- KAFKA\_ADVERTISED\_LISTENERS should be PLAINTEXT://localhost:9092,PLAINTEXT\_INTERNAL://kafka-service:29092
- KAFKA\_OFFSETS\_TOPIC\_REPLICATION\_FACTOR should be "**1**"
- KAFKA\_AUTO\_CREATE\_TOPICS\_ENABLE should be "**true**"

***Note**: By default minikube starts with limited resources, you may need to increase them when starting minikube.*

**Step 2: Charting the way forward (20 pts)**

In this step, we will be implementing neo4j in our setup. You already have a firm grasp on neo4j and the ins and out of its container. However, for this project, since the data will be streamed, we can simply utilize neo4j setups that are [available](https://neo4j.com/docs/operations-manual/current/kubernetes/) for Kubernetes.

We already have helm and the neo4j repository present in helm. Refer the grader.md file provided to see how your command will be tested in the grading environment.

We will be using neo4j in standalone mode, however, the cluster mode can also be set up in almost the same way (with a enterprise licence). The following diagram shows what all should be set up by the end of this step.

![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.007.jpeg)

**Hints:**

- The last step showed part of the environment setup, this step continues with the same while introducing another integral part of it, neo4j. Make sure to go through the guide to setting up standalone neo4j instances in kubernetes, it explains all the important steps.
- Make sure to set up the password to be project2phase2 in your yaml file (and also to have the gds library installed). The documentation for installation will help you with this. This yaml file should be named asneo4j-values.yaml and submitted to canvas.![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.008.png)
- We have additionally also provided aneo4j-service.yaml file that you can modify (if needed) and use to start a service. This service will allow neo4j inside kubernetes to have ports accessible through neo4j-service:7474 that allows it to communicate within the network. Note that your network is still only accessible inside the minikube environment, step 4 will show how to access your neo4j browser outside the minikube environment.

**Step 3: Neo4j -> [<3] -> Kafka (20 pts)**

In this step, Kafka and Neo4j will be connected. There are tools already available for this, specifically the kafka connect extension that we will utilize.

We have already done a lot of the setup required for this step and you majorly need to write the yaml file that launces this custom image. This custom image converts the data received from the kafka topic into data interpretable by neo4j. The following diagram shows what all should be set up by the end of this step.

![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.009.jpeg)

**Hints:**

- You can refer the documentation for [Kafka Connect neo4j](https://neo4j.com/docs/kafka/) which is what we will be using for this stage of the project. A custom image that has the neo4j connector already installed is also made available to you at veedata/kafka-neo4j-connect.
- We have also uploaded the Dockerfile for this step to the dropbox folder in case you need to refer it or are curious on what goes on inside the container.
- Make sure to write the steps you use for this step in a bash file and submit it as well! The name of the file should be kafka-neo4j-connection.yaml.

**Step 4: PA T PB (30 pts)**

![](Aspose.Words.9d08f230-e61e-45e6-ad9b-86c77738d35c.010.png)

By this step, you should have everything put together. You can try to run the data\_producer.py file provided to you at this point. The data should have a high-level flow in the following manner: *producer => enter kubernetes environment => (kbe) kafka => (kbe) neo4j => exit kubernetes environment => data analytics*. The same **two** algorithms from phase 1 of the project will be utilized again: **PageRank,** and **Breadth-First Search (BFS).** You need to implement them in the interface.py file provided.

Do note that you need to expose the ports outside your minikube environment in this step. A template of how you do this is present in the grader.md file.
