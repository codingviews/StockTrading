# Stock Trading Platform – High Level Design

*Derived from the architecture sketch "You Buy Stock. What Happens Next?" Stack: Spring Boot, JWT, WebSocket, Kafka, Redis, Claude AI.*

## 1. Purpose and Scope

This document describes the high-level architecture of a simulated stock trading platform. It covers the main services, how they communicate, and what happens end to end when a user buys a stock. It is intentionally not a low-level design: schemas, API contracts and class design are out of scope.

Items marked **(Assumption)** were hard to read or not explicit in the sketch and should be confirmed.

## 2. Goals

- Let users register, log in, and hold a virtual wallet with a starting balance (10,000 shown in the sketch).
- Stream simulated live stock prices to clients.
- Place buy/sell orders and execute them reliably.
- Maintain portfolio holdings and profit/loss (P&L) per user.
- Notify users of important events.
- Provide AI-powered insights using a Python-based AI service (OpenAI / Claude AI).

## 3. Architecture Overview

```
                         Client
                           |
                      API Gateway
          +-------+--------+---------+-----------+
          |       |        |         |           |
     User Service  Market Data   Order Service  Portfolio
    (reg/login,    Service       (buy/sell)     Service
     wallet)       (WebSocket)       |          (P&L calc)
          |            |            |              ^
          |            +--> AI Service (Python) <----+ (order data)
          |            |            |              |
          +------------+------------+--------------+
                           |
                 Apache Kafka (Event Stream)
                           |
                 Notification Service
```

The Client talks only to the **API Gateway**, which routes requests to four core services. Services publish domain events to **Apache Kafka**, and downstream consumers (Portfolio, Notification, AI) react to those events asynchronously. Dashed lines in the sketch between User, Market Data and Order services indicate direct service-to-service calls **(Assumption: synchronous REST)**.

## 4. Components

### 4.1 API Gateway

- Single entry point for all client traffic.
- Routes to User, Market Data, Order and Portfolio services.
- Validates JWT tokens, so downstream services receive authenticated requests.
- Natural place for rate limiting and request logging **(Assumption)**.

### 4.2 User Service

- User registration and login (JWT issued on login).
- Wallet management, including the initial balance of 10,000 on registration.
- Publishes user events (for example registration, wallet changes) to Kafka **(Assumption)**.

### 4.3 Market Data Service (WebSocket)

- Simulates stock prices and pushes real-time updates to clients over WebSocket.
- Caches the latest price per stock in **Redis** so other services can read current prices cheaply.
- Publishes price events to Kafka and feeds the AI Service.

### 4.4 Order Service (Buy / Sell)

- Accepts buy and sell orders from the client via the gateway.
- Reads the latest price (from Redis / Market Data) and checks wallet balance or holdings via the User Service.
- Publishes order events to Kafka, including **OrderPlaced** and **OrderExecuted**.
- Sends order context to the AI Service for analysis **(Assumption)**.

### 4.5 Portfolio Service (P&L Calculation)

- Consumes **OrderExecuted** events from Kafka.
- Updates the user's holdings after each executed order.
- Calculates profit and loss using holdings and latest prices.
- Serves portfolio queries from the client via the gateway.

### 4.6 AI Service (Python)

- Separate Python service integrating with OpenAI / Claude AI.
- Receives market data and order information, and produces insights such as summaries, explanations or recommendations.
- Kept separate from the Java services so it can scale and evolve independently.

### 4.7 Apache Kafka (Event Stream)

- Central event backbone that decouples producers from consumers.
- Carries user, market, order and notification-related events.
- Provides durability and replay for downstream consumers.

### 4.8 Notification Service

- Consumes all events from Kafka.
- Sends notifications to users, such as order executed or order failed **(channels are an Assumption: in-app, email or push)**.

## 5. Technology Stack

| Concern | Technology |
| --- | --- |
| Service framework | Spring Boot (Java) |
| Authentication | JWT |
| Real-time prices | WebSocket |
| Event streaming | Apache Kafka |
| Caching (latest prices) | Redis |
| AI integration | Python service using OpenAI / Claude AI |
| Entry point | API Gateway |

## 6. Key Flow: "You Buy Stock. What Happens Next?"

1. **Login.** The client authenticates through the gateway; the User Service issues a JWT. The wallet starts with 10,000.
2. **Live prices.** The client opens a WebSocket to the Market Data Service and receives simulated price updates. The latest price per stock is cached in Redis.
3. **Place order.** The client sends a buy request through the API Gateway to the Order Service.
4. **Validate.** The Order Service checks the current price (Redis) and the user's wallet balance (User Service).
5. **Execute.** The order is executed and an **OrderExecuted** event is published to Kafka.
6. **Consume.** The Portfolio Service consumes the event, updates holdings and recalculates P&L. The User Service updates the wallet **(Assumption: via event or direct call)**.
7. **Notify.** The Notification Service consumes the event and informs the user.
8. **Insights.** The AI Service can use market and order data to generate insights for the user.

## 7. Data and Communication Patterns

| Interaction | Style |
| --- | --- |
| Client to services | Synchronous HTTPS via API Gateway |
| Price streaming to client | WebSocket (push) |
| Service-to-service lookups | Synchronous calls (dashed lines in sketch) |
| Order, portfolio and notification updates | Asynchronous events via Kafka |
| Latest price lookup | Redis cache |

## 8. Non-Functional Considerations

- **Scalability:** Services are independently deployable and scalable; Kafka absorbs bursts from order and market traffic.
- **Reliability:** Event-driven flow lets consumers recover and replay events after failure. Order execution should be idempotent.
- **Consistency:** Wallet and holdings updates are eventually consistent across services. Consider the saga or outbox pattern for order, wallet and portfolio updates.
- **Security:** JWT validated at the gateway; service-to-service traffic should be internal-only; secrets for AI providers stored securely.
- **Performance:** Redis keeps price reads fast; WebSocket avoids polling.
- **Observability:** Centralized logging, metrics and distributed tracing across services.

## 9. Open Questions

- Does each service own its own database? (Typical for microservices; not shown in the sketch.)
- Is wallet debit handled synchronously by the Order Service or through events?
- Exactly what does the AI Service consume (market data only, or orders too) and what does it return to the user?
- Which notification channels are supported?
- How is the market simulator seeded and scheduled (the sketch's price simulator note is partly illegible)?

## 10. Future Enhancements

- Order types such as limit and stop orders.
- Real market data provider integration.
- Portfolio analytics and AI-driven recommendations.
- Service discovery, circuit breakers and resilience patterns.
