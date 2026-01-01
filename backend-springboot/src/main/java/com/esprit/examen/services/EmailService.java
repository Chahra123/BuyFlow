package com.esprit.examen.services;

import javax.mail.MessagingException;
import javax.mail.internet.MimeMessage;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class EmailService {

    private final JavaMailSender mailSender;

    @Value("${spring.mail.username}")
    private String fromEmail;

    @Async
    public void sendEmail(String to, String subject, String content) {
        System.out.println("==============================================");
        System.out.println("EMISSION D'EMAIL (SERVICE)");
        System.out.println("Destinataire : " + to);
        System.out.println("Objet        : " + subject);
        System.out.println("Contenu      : \n" + content);
        System.out.println("==============================================");

        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true);

            helper.setFrom("no-reply@buyflow.com");
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(content, true); // true for HTML

            System.out.println("Tentative d'envoi SMTP (Gmail)...");
            mailSender.send(message);
            System.out.println("✅ EMAIL ENVOYÉ avec succès à " + to);
        } catch (MessagingException e) {
            System.err.println("⚠️ SMTP ERROR : Impossible d'envoyer l'email.");
            System.err.println("Vérifiez vos identifiants Gmail et le mot de passe d'application.");
            System.err.println("Assurez-vous que l'accès IMAP/POP est activé si nécessaire.");
        } catch (Exception e) {
            System.err.println("❌ Erreur inattendue lors de l'envoi : " + e.getMessage());
        }
    }
}
