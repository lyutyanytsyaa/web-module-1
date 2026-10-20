const express = require("express");
const service = require("../services/orders");

const router = express.Router();

function orderResponse(order) {
  return {
    id: order.id,
    customerName: order.customerName,
    items: order.items.map(({ name, quantity, price }) => ({
      name,
      quantity,
      price,
    })),
    total: order.total,
    status: order.status,
  };
}

function validationProblem(message, details) {
  return { error: { code: "VALIDATION_ERROR", message, details } };
}

function notFoundProblem() {
  return { error: { code: "ORDER_NOT_FOUND", message: "Order not found" } };
}

router.post("/", (req, res) => {
  const { errors, order } = service.createOrder(req.body);

  if (errors) {
    return res.status(400).json(validationProblem("Invalid order", errors));
  }

  return res.status(201).location(`/orders/${order.id}`).json(orderResponse(order));
});

router.get("/", (req, res) => {
  const orders = service.listOrders().map(orderResponse);
  res.status(200).json({ orders, count: orders.length });
});

router.get("/:id", (req, res) => {
  const order = service.getOrder(req.params.id);

  if (!order) {
    return res.status(404).json(notFoundProblem());
  }

  return res.status(200).json(orderResponse(order));
});

router.delete("/:id", (req, res) => {
  if (!service.deleteOrder(req.params.id)) {
    return res.status(404).json(notFoundProblem());
  }

  return res.status(204).send();
});

module.exports = router;