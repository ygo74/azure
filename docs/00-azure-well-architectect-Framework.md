---
layout: default
title: Azure Well Architected Framework
nav_order: 2
has_children: true
---


## Reliability

### Keep the Workload simple and efficient

- Goal to keep our workload simple
- Utilize platform functionality where appropriate
- Abstract domain logic implementation from infrastructure management (see DAPR)
- Offload cross-cutting concerns to a separate service (see DAPR)
- Cross-cutting services to separate services (avoid duplicate code for cross-cutting services)
- Define functional and nonfunctional requirements
- Decompose workloads into components.
- Define availability and recovery targets (SLO, SLA, MTTR, MTBF, RTO, RPO)
- Concede that all successful applications change over time (application deployment => devops, application review)
- Use platform as a service (PaaS) options
- Use asynchronous messaging
- Develop just enough code
  - Use platform capabilities when they meet your business requirements. For example, to offload development and management, use low-code, no-code, or serverless solutions that your cloud provider offers.
  - Use libraries and frameworks.
  - Introduce pair programming or dedicated code review sessions as a development practice
  - Implement an approach to identify dead code. Be skeptical of the code that your automated tests don't cover.
- Use the best data store for your data  

### Understand the workload's flows

- Catalog of all supported flows to provide awareness for our team
- Understand and document the business process that each flow supports 
- Set and published organizational agreements, like ownership and escalation paths
- Define and assign a criticality level to your workload's user flows and system flows
- Use failure mode analysis
- Target metrics
- Build a healtyh model

### High availability

- Availability zones within a single region
- Active - Active
  - At capacity
  - overprovisioned
- Active - Passive
  - Warm spare
  - Cold spare
  - redeploy on disaster


### Design patterns for reliability

https://learn.microsoft.com/en-us/azure/well-architected/reliability/design-patterns


## Cloud native application

https://azure.microsoft.com/en-us/solutions/cloud-native-apps/

### Microservices

- Built and deployed independently
- Distributed and loosely coupled
- Communicate with well-defined API contracts
- Domain analysis using Domain driven design and microservice boundaries


### Serverless

App Goals :

- Apply low-cost, high-value code changes
- Reach a service level objective of 99.9%
- Adopt DevOps practices
- Create cost-optimized environments
- Improve reliability and security

- Expose the application to customers
- Develop web and mobile experiences
- Improve availability
- Expedite new feature delivery
- Scale components based on traffic.


Reliable web app pattern principles:
▪ Minimal code changes
▪ Reliability design patterns
▪ Managed services

Well Architected Framework principles:
▪ Cost optimized
▪ Observable
▪ Ingress secure
▪ Infrastructure as code
▪ Identity-centric security

▪ Retry pattern
▪ Circuit-breaker pattern
▪ Cache-aside pattern
▪ Rightsized resources
▪ Managed identities
▪ Private endpoints
▪ Secrets management
▪ Bicep deployment
▪ Telemetry, logging, monitoring



Java : https://github.com/resilience4j/resilience4j
dotnet : https://github.com/App-vNext/Polly



## Azure Services catalog

| services | Summary |
|:- |:- |
| [Azure functions](https://azure.microsoft.com/products/functions) | Is a serverless compute service that you can use to build orchestration with minimal code.|
| [Azure Logic Apps](https://azure.microsoft.com/products/logic-apps) | is a serverless workflow integration platform that you can use to build orchestration with a GUI or by editing a configuration file |
| [Azure Event Grid](https://azure.microsoft.com/products/event-grid) | is a highly scalable, fully managed publish-subscribe message distribution service that offers flexible message consumption patterns that use the MQTT and HTTP protocols |
| [Azure monitor](https://learn.microsoft.com/en-us/azure/azure-monitor/overview) ||
| [Log Analytics](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview) ||
| [Application Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview) ||
| [Container Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-overview) ||
| [Network Insights](https://learn.microsoft.com/en-us/azure/network-watcher/network-insights-overview) ||
| [VM Insights](https://learn.microsoft.com/en-us/azure/azure-monitor/vm/vminsights-overview) ||
| [SQL Insights](https://learn.microsoft.com/en-us/azure/azure-sql/database/sql-insights-overview) ||
| [Azure Chaos Studio](https://azure.microsoft.com/services/chaos-studio) ||
| [Azure Front door](https://azure.microsoft.com/products/frontdoor) | combines the global routing functionality of Azure Traffic Manager with a content delivery system and web application firewall |
| [Azure Cosmos DB](https://learn.microsoft.com/en-us/azure/cosmos-db/introduction) | Is a globally distributed NoSQL database platform that can help you run an active-active environment |


