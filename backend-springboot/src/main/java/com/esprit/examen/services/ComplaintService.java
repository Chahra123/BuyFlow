package com.esprit.examen.services;

import com.esprit.examen.dto.CreateComplaintRequest;
import com.esprit.examen.dto.SendMessageRequest;
import com.esprit.examen.entities.*;
import com.esprit.examen.exception.BadRequestException;
import com.esprit.examen.exception.ResourceNotFoundException;
import com.esprit.examen.repositories.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.Principal;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ComplaintService {

    private final ComplaintRepository complaintRepository;
    private final ComplaintMessageRepository messageRepository;
    private final CustomerOrderRepository orderRepository;
    private final UserRepository userRepository;

    private User getConnectedUser(Principal principal) {
        if (principal == null) throw new BadRequestException("Missing authentication");
        return userRepository.findByEmail(principal.getName())
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));
    }

    public List<Complaint> myComplaints(Principal principal) {
        User user = getConnectedUser(principal);
        return complaintRepository.findByUserOrderByCreatedAtDesc(user);
    }

    public Complaint getMyComplaint(Long complaintId, Principal principal) {
        User user = getConnectedUser(principal);
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found"));

        if (!complaint.getUser().getId().equals(user.getId()) && user.getRole() != Role.ADMIN) {
            throw new org.springframework.security.access.AccessDeniedException("Not allowed");
        }
        // load messages
        complaint.setMessages(messageRepository.findByComplaintOrderBySentAtAsc(complaint));
        return complaint;
    }

    @Transactional
    public Complaint createComplaint(CreateComplaintRequest request, Principal principal) {
        User user = getConnectedUser(principal);
        CustomerOrder order = orderRepository.findById(request.getOrderId())
                .orElseThrow(() -> new ResourceNotFoundException("Order not found"));
        if (!order.getUser().getId().equals(user.getId()) && user.getRole() != Role.ADMIN) {
            throw new org.springframework.security.access.AccessDeniedException("Not allowed");
        }

        Complaint complaint = Complaint.builder()
                .user(user)
                .order(order)
                .category(request.getCategory())
                .status(ComplaintStatus.OPEN)
                .description(request.getDescription())
                .build();

        Complaint saved = complaintRepository.save(complaint);

        if (request.getDescription() != null && !request.getDescription().isBlank()) {
            ComplaintMessage msg = ComplaintMessage.builder()
                    .complaint(saved)
                    .sender(user)
                    .content(request.getDescription())
                    .build();
            messageRepository.save(msg);
        }
        return saved;
    }

    @Transactional
    public ComplaintMessage sendMessage(Long complaintId, SendMessageRequest request, Principal principal) {
        User sender = getConnectedUser(principal);
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found"));

        if (sender.getRole() != Role.ADMIN && !complaint.getUser().getId().equals(sender.getId())) {
            throw new org.springframework.security.access.AccessDeniedException("Not allowed");
        }
        if (complaint.getStatus() == ComplaintStatus.CLOSED) {
            throw new BadRequestException("Complaint is closed");
        }

        if (sender.getRole() == Role.ADMIN && complaint.getStatus() == ComplaintStatus.OPEN) {
            complaint.setStatus(ComplaintStatus.IN_PROGRESS);
            complaintRepository.save(complaint);
        }

        ComplaintMessage message = ComplaintMessage.builder()
                .complaint(complaint)
                .sender(sender)
                .content(request.getContent())
                .build();
        return messageRepository.save(message);
    }

    // Admin endpoints
    public List<Complaint> allComplaints() {
        return complaintRepository.findAll();
    }

    @Transactional
    public Complaint updateStatus(Long complaintId, ComplaintStatus status) {
        Complaint complaint = complaintRepository.findById(complaintId)
                .orElseThrow(() -> new ResourceNotFoundException("Complaint not found"));
        complaint.setStatus(status);
        return complaintRepository.save(complaint);
    }
}
