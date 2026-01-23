# BuyFlow — Orders / Delivery / Complaints / Invoice (Backend)

This backend adds 4 modules:

1. Orders (multi-items)
2. Courier assignment + QR delivery confirmation
3. Complaints + chat messages (polling-friendly)
4. Invoice PDF generation on-demand

## Key business rules
- DB: MySQL
- Stock decrement: **at order confirmation** (when the order is created), using `MouvementStock`:
  - each order line creates one `SORTIE` movement
- Cancellation: allowed **only before courier assignment**. Cancellation creates `ENTREE` movements to restore stock.
- Online payment: not implemented, but `PaymentStatus` is present for future extension.

## Endpoints

### Orders (authenticated)
- `GET /api/orders` : list my orders (admin can also access any by id)
- `GET /api/orders/{id}` : get order details
- `POST /api/orders` : create order
- `POST /api/orders/{id}/cancel` : cancel order (only before assignment)
- `GET /api/orders/{id}/qr` : returns `{"qrData":"ORDER:{id}:{deliveryToken}"}`
- `GET /api/orders/{id}/invoice` : invoice PDF download

**Create order payload**
```json
{
  "items": [
    {"produitId": 1, "quantity": 2},
    {"produitId": 5, "quantity": 1}
  ],
  "deliveryAddress": "Rue X, Tunis",
  "deliveryLat": 36.8,
  "deliveryLng": 10.18,
  "deliveryInstructions": "Etage 2",
  "paymentMethod": "COD"
}
```

### Courier (ROLE_LIVREUR)
Base path: `/api/delivery/orders`
- `GET /api/delivery/orders` : orders assigned to the courier (statuses ASSIGNED/OUT_FOR_DELIVERY)
- `POST /api/delivery/orders/{id}/start` : sets status to OUT_FOR_DELIVERY
- `POST /api/delivery/orders/{id}/scan` : validate delivery with QR

Scan payload:
```json
{"qrData": "ORDER:123:abcd..."}
```

### Complaints (authenticated)
- `GET /api/complaints` : list my complaints
- `GET /api/complaints/{id}` : complaint details + messages
- `POST /api/complaints` : create complaint (order must belong to user)
- `POST /api/complaints/{id}/messages` : send chat message

### Complaints admin (ROLE_ADMIN)
- `GET /api/admin/complaints` : list all complaints
- `POST /api/admin/complaints/{id}/status?status=IN_PROGRESS|RESOLVED|CLOSED` : update status

### Orders admin (ROLE_ADMIN)
- `POST /api/admin/orders/{id}/assign` : assign courier
Payload (optional):
```json
{"courierUserId": 42}
```
If omitted/null, the system auto-assigns the first available LIVREUR.

## Notes
- Requires JWT auth already present in the project.
- Uses JPA `ddl-auto=update` (no Flyway/Liquibase).
- Invoice PDF uses OpenPDF; optional QR is embedded using ZXing.
