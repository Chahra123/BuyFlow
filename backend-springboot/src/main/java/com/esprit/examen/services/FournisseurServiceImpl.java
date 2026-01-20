package com.esprit.examen.services;

import java.util.Date;
import java.util.List;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import com.esprit.examen.entities.DetailFournisseur;
import com.esprit.examen.entities.Fournisseur;
import com.esprit.examen.entities.SecteurActivite;
import com.esprit.examen.repositories.DetailFournisseurRepository;
import com.esprit.examen.repositories.FournisseurRepository;
import com.esprit.examen.repositories.ProduitRepository;
import com.esprit.examen.repositories.SecteurActiviteRepository;
import lombok.extern.slf4j.Slf4j;
import org.springframework.transaction.annotation.Transactional;

@Service
@Slf4j
@RequiredArgsConstructor
public class FournisseurServiceImpl implements IFournisseurService {

	private final FournisseurRepository fournisseurRepository;
	private final DetailFournisseurRepository detailFournisseurRepository;
	private final SecteurActiviteRepository secteurActiviteRepository;

	@Override
	public List<Fournisseur> retrieveAllFournisseurs() {
		return fournisseurRepository.findAll();
	}


	public Fournisseur addFournisseur(Fournisseur f) {
		fournisseurRepository.save(f);
		return f;
	}
	
	private DetailFournisseur saveDetailFournisseur(Fournisseur f){
		DetailFournisseur df = f.getDetailFournisseur();
		detailFournisseurRepository.save(df);
		return df;
	}

	public Fournisseur updateFournisseur(Fournisseur f) {
		saveDetailFournisseur(f);
		fournisseurRepository.save(f);
		return f;
	}

	@Override
	public void deleteFournisseur(Long fournisseurId) {
		fournisseurRepository.deleteById(fournisseurId);
	}

	@Override
	public Fournisseur retrieveFournisseur(Long fournisseurId) {
		return fournisseurRepository.findById(fournisseurId).orElse(null);
	}

	@Transactional
	@Override
	public void assignSecteurActiviteToFournisseur(Long idSecteurActivite, Long idFournisseur) {
		Fournisseur fournisseur = fournisseurRepository.findById(idFournisseur).orElse(null);
		SecteurActivite secteurActivite = secteurActiviteRepository.findById(idSecteurActivite).orElse(null);
        if (fournisseur != null && secteurActivite != null) {
            fournisseur.getSecteurActivites().add(secteurActivite);
            fournisseurRepository.save(fournisseur);
        }
	}

	

}
