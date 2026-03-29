package com.ecommerce.service;

import com.ecommerce.model.Category;
import com.ecommerce.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CategoryService {
    
    @Autowired
    private CategoryRepository categoryRepository;
    
    /**
     * Get all categories
     */
    public List<Category> getAllCategories() {
        return categoryRepository.findAll();
    }
    
    /**
     * Get category by ID
     */
    public Optional<Category> getCategoryById(Long id) {
        return categoryRepository.findById(id);
    }
    
    /**
     * Create a new category
     */
    public Category createCategory(Category category) {
        // Check if category name already exists
        if (categoryRepository.existsByName(category.getName())) {
            throw new RuntimeException("Category with name '" + category.getName() + "' already exists!");
        }
        
        // Auto-generate slug from name if not provided
        if (category.getSlug() == null || category.getSlug().isEmpty()) {
            category.setSlug(category.getName().toLowerCase().replaceAll("\\s+", "-"));
        }
        
        return categoryRepository.save(category);
    }
    
    /**
     * Update an existing category
     */
    public Category updateCategory(Long id, Category categoryDetails) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + id));
        
        // Update fields
        if (categoryDetails.getName() != null && !categoryDetails.getName().equals(category.getName())) {
            // Check if new name is already used
            if (categoryRepository.existsByName(categoryDetails.getName())) {
                throw new RuntimeException("Category with name '" + categoryDetails.getName() + "' already exists!");
            }
            category.setName(categoryDetails.getName());
        }
        
        if (categoryDetails.getDescription() != null) {
            category.setDescription(categoryDetails.getDescription());
        }
        
        if (categoryDetails.getSlug() != null) {
            category.setSlug(categoryDetails.getSlug());
        }
        
        if (categoryDetails.getIsActive() != null) {
            category.setIsActive(categoryDetails.getIsActive());
        }
        
        return categoryRepository.save(category);
    }
    
    /**
     * Delete a category
     */
    public void deleteCategory(Long id) {
        Category category = categoryRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Category not found with id: " + id));
        categoryRepository.delete(category);
    }
    
    /**
     * Get category by name
     */
    public Optional<Category> getCategoryByName(String name) {
        return categoryRepository.findByName(name);
    }
    
    /**
     * Get category by slug
     */
    public Optional<Category> getCategoryBySlug(String slug) {
        return categoryRepository.findBySlug(slug);
    }
}
