package com.esprit.examen.controllers;

import com.esprit.examen.entities.Complaint;
import com.esprit.examen.entities.ComplaintStatus;
import com.esprit.examen.services.ComplaintService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/admin/complaints")
@CrossOrigin("*")
@RequiredArgsConstructor
public class AdminComplaintController {

    private final ComplaintService complaintService;

    @GetMapping
    public List<Complaint> all() {
        return complaintService.allComplaints();
    }

    @PostMapping("/{id}/status")
    public Complaint setStatus(@PathVariable Long id, @RequestParam ComplaintStatus status) {
        return complaintService.updateStatus(id, status);
    }
}
