

**欢迎**

欢迎来到 Geospatial for Java。本教程面向对地理空间领域不熟悉但希望入门的 Java 开发者。

在学习本教程之前，你应该已经完成了 GeoTools 的一个快速入门（Quickstart）。这样可以确保你的环境已经配置好，包括 GeoTools 的 JAR 包及其所有依赖项。在本教程开始时，我们会列出所需的 Maven 依赖项。

本教程将演示如何在 GeoTools 中查询空间数据。在之前的教程中，我们主要使用了 Shapefile（矢量数据格式）。本教程的重点是使用 **Filter API** 查询 **DataStore**，如 Shapefile、数据库以及 Web Feature Server（WFS）。因此，在本实验中，我们将使用一个真正的空间数据库。

如果你所在的企业已经使用了空间数据库（例如 Oracle、DB2）或地理空间中间件，你可以使用 GeoTools 连接到现有基础设施。在本教程中，我们将使用 **PostGIS**，它是 PostgreSQL 的空间扩展，支持 SQL 的简单要素（Simple Features）。我们将构建一个应用程序，该应用程序可以同时连接 **PostGIS 数据库**和 **Shapefile**。

本教程采用 **代码优先** 的方式 —— 你将从源码开始学习，并在实践中探索其中的概念，如果有疑问，可以随时深入理解。