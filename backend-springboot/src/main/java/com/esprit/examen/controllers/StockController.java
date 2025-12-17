package com.esprit.examen.controllers;

import com.esprit.examen.entities.Stock;
import com.esprit.examen.services.IStockService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;


@RestController
@RequestMapping("/stocks")
@CrossOrigin("*")
@RequiredArgsConstructor
public class StockController {

    private final IStockService stockService;

    @GetMapping("/{id}")
    public Stock retrieveStock(@PathVariable Long id) {
        return stockService.retrieveStock(id);
    }

    @DeleteMapping("/{id}")
    public void removeStock(@PathVariable Long id) {
        stockService.deleteStock(id);
    }

    @GetMapping
    public List<Stock> getStocks() {
        return stockService.retrieveAllStocks();
    }

    @PostMapping
    public Stock addStock(@RequestBody Stock s) {
        return stockService.addStock(s);
    }

    @PutMapping
    public Stock modifyStock(@RequestBody Stock stock) {
        return stockService.updateStock(stock);
    }
}
