package com.esprit.examen.services;

import com.esprit.examen.entities.CustomerOrder;
import com.esprit.examen.entities.CustomerOrderItem;
import com.esprit.examen.exception.ResourceNotFoundException;
import com.esprit.examen.repositories.CustomerOrderRepository;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.WriterException;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.lowagie.text.*;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.math.BigDecimal;
import java.time.format.DateTimeFormatter;

import javax.imageio.ImageIO;

@Service
@RequiredArgsConstructor
public class InvoiceService {

    private final CustomerOrderRepository orderRepository;

    public byte[] generateInvoicePdf(Long orderId) {
        CustomerOrder order = orderRepository.findById(orderId)
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));

        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            Document document = new Document(PageSize.A4);
            PdfWriter.getInstance(document, baos);
            document.open();

            Font titleFont = new Font(Font.HELVETICA, 18, Font.BOLD);
            Font normal = new Font(Font.HELVETICA, 11);

            document.add(new Paragraph("Invoice", titleFont));
            document.add(new Paragraph("Order #" + order.getId(), normal));
            if (order.getCreatedAt() != null) {
                document.add(new Paragraph("Date: " + order.getCreatedAt().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME), normal));
            }
            document.add(new Paragraph("Customer: " + order.getUser().getFirstName() + " " + order.getUser().getLastName() + " (" + order.getUser().getEmail() + ")", normal));
            document.add(new Paragraph("Delivery address: " + order.getDeliveryAddress(), normal));
            document.add(Chunk.NEWLINE);

            PdfPTable table = new PdfPTable(4);
            table.setWidthPercentage(100);
            table.addCell("Product");
            table.addCell("Qty");
            table.addCell("Unit price");
            table.addCell("Line total");

            for (CustomerOrderItem item : order.getItems()) {
                table.addCell(item.getProduit().getLibelleProduit());
                table.addCell(String.valueOf(item.getQuantity()));
                table.addCell(toMoney(item.getUnitPrice()));
                table.addCell(toMoney(item.getLineTotal()));
            }
            document.add(table);
            document.add(Chunk.NEWLINE);

            document.add(new Paragraph("Subtotal: " + toMoney(order.getSubtotal()), normal));
            document.add(new Paragraph("Shipping: " + toMoney(order.getShippingFee()), normal));
            document.add(new Paragraph("Total: " + toMoney(order.getTotal()), new Font(Font.HELVETICA, 12, Font.BOLD)));

            // Optional QR code for internal verification
            document.add(Chunk.NEWLINE);
            Image qr = generateQrImage("ORDER:" + order.getId() + ":" + order.getDeliveryToken());
            if (qr != null) {
                qr.scaleToFit(120, 120);
                document.add(new Paragraph("Delivery QR", normal));
                document.add(qr);
            }

            document.close();
            return baos.toByteArray();
        } catch (Exception e) {
            throw new RuntimeException("Failed to generate invoice PDF: " + e.getMessage(), e);
        }
    }

    private String toMoney(BigDecimal v) {
        if (v == null) return "0.000";
        return v.setScale(3, BigDecimal.ROUND_HALF_UP).toPlainString();
    }

    private Image generateQrImage(String text) {
        try {
            QRCodeWriter qrCodeWriter = new QRCodeWriter();
            BitMatrix bitMatrix = qrCodeWriter.encode(text, BarcodeFormat.QR_CODE, 250, 250);
            BufferedImage bufferedImage = new BufferedImage(250, 250, BufferedImage.TYPE_INT_RGB);
            for (int x = 0; x < 250; x++) {
                for (int y = 0; y < 250; y++) {
                    int val = bitMatrix.get(x, y) ? 0x000000 : 0xFFFFFF;
                    bufferedImage.setRGB(x, y, val);
                }
            }
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(bufferedImage, "PNG", baos);
            return Image.getInstance(baos.toByteArray());
        } catch (WriterException | java.io.IOException | BadElementException e) {
            return null;
        }
    }
}
