/*
========================================================
Proyecto: Sales Analytics
Base de Datos: AdventureWorks2025
Autor: Jheanpierr CObba
Descripción:
	Análisis de pedidos por cliente utilizando CTE y 
	Window Functions.
========================================================
*/



-- Calculamos el Total de cada Pedido --
-- Necesitamos sumar LINETOTAL del SALESORDERDETAIL --
-- Agrupando por SalesOrderID

WITH PedidoTotales AS (
	SELECT sod.SalesOrderID, SUM(sod.LineTotal) AS TotalPedido
	FROM Sales.SalesOrderDetail sod
	GROUP BY sod.SalesOrderID
),


-- Unimos info con el encabezado del pedido y con la tablas --
-- de cliente y persona para obtener el nombre --

PedidosConRanking AS (

	SELECT soh.SalesOrderID, soh.OrderDate, soh.CustomerID, 
		p.FirstName + ' ' + p.LastName AS NombreCliente,
		pt.TotalPedido,

			-- Total Acumulado por Cliente --
			SUM(pt.TotalPedido) OVER (PARTITION BY soh.CustomerID ORDER BY soh.OrderDate, soh.SalesOrderID
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS TotalAcumuladoCliente,
		
			-- Ranking del pedido por monto dentro del cliente --
			RANK() OVER(PARTITION BY soh.CustomerID
			ORDER BY pt.TotalPedido DESC) AS RankingDentroCliente

	FROM Sales.SalesOrderHeader soh

	-- Unimos con la CTE que contiene el Total del Pedido --
	INNER JOIN PedidoTotales pt
	ON soh.SalesOrderID = pt.SalesOrderID

	-- Unimos con Cliente --
	INNER JOIN Sales.Customer c 
	ON soh.CustomerID = c.CustomerID

	-- Unimos con persona para el nombre --
	INNER JOIN Person.Person p
	ON c.PersonID = p.BusinessEntityID
	)

SELECT *,
	CASE WHEN RankingDentroCliente = 1 
		THEN 'SI'
		ELSE 'NO'
	END AS EsPedidoMasGrande
FROM PedidosConRanking
ORDER BY CustomerID, OrderDate, SalesOrderID;