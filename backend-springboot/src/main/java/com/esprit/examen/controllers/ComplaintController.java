package com.esprit.examen.controllers;

import com.esprit.examen.dto.CreateComplaintRequest;
import com.esprit.examen.dto.SendMessageRequest;
import com.esprit.examen.entities.Complaint;
import com.esprit.examen.entities.ComplaintMessage;
import com.esprit.examen.services.ComplaintService;
import lombok.RequiredArgsConstructor;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/complaints")
@CrossOrigin("*")
@RequiredArgsConstructor
@Validated
public class ComplaintController {

    private final ComplaintService complaintService;

    @GetMapping
    public List<Complaint> myComplaints(Principal principal) {
        return complaintService.myComplaints(principal);
    }

    @GetMapping("/{id}")
    public Complaint get(@PathVariable Long id, Principal principal) {
        return complaintService.getMyComplaint(id, principal);
    }

    @PostMapping
    public Complaint create(@Valid @RequestBody CreateComplaintRequest request, Principal principal) {
        return complaintService.createComplaint(request, principal);
    }

    @PostMapping("/{id}/messages")
    public ComplaintMessage send(@PathVariable Long id, @Valid @RequestBody SendMessageRequest request, Principal principal) {
        return complaintService.sendMessage(id, request, principal);
    }
}
