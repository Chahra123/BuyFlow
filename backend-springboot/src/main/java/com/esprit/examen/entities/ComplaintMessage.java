package com.esprit.examen.entities;

import lombok.*;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ComplaintMessage {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(optional = false)
    @com.fasterxml.jackson.annotation.JsonIgnore
    private Complaint complaint;

    @ManyToOne(optional = false)
    private User sender;

    @Column(length = 2000, nullable = false)
    private String content;

    private LocalDateTime sentAt;

    @PrePersist
    void onCreate() {
        sentAt = LocalDateTime.now();
    }
}
