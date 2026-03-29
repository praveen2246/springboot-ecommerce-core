# Contributing Guidelines

**Welcome to the E-Commerce Platform project!** We appreciate your interest in contributing. This document provides guidelines for contributing to the project.

---

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [Code Style & Standards](#code-style--standards)
4. [Commit Guidelines](#commit-guidelines)
5. [Pull Request Process](#pull-request-process)
6. [Testing Requirements](#testing-requirements)
7. [Documentation Requirements](#documentation-requirements)
8. [Common Issues](#common-issues)

---

## 🚀 Getting Started

### Prerequisites
- Java 17 or higher
- Node.js 18+ with npm
- Maven 3.8+
- Git
- PostgreSQL 12+ (for production setup)
- IDE (VS Code, IntelliJ IDEA)

### Fork & Clone the Repository

```bash
# 1. Fork on GitHub
# Visit: https://github.com/praveen2246/springboot-ecommerce-core
# Click "Fork" button

# 2. Clone your fork
git clone https://github.com/<your-username>/springboot-ecommerce-core.git
cd springboot-ecommerce-core

# 3. Add upstream remote
git remote add upstream https://github.com/praveen2246/springboot-ecommerce-core.git

# 4. Create development branch
git checkout -b develop
git pull upstream develop
```

---

## 🔧 Development Setup

### Backend Setup

```bash
cd ecommerce-backend/ecommerce-backend

# Copy environment template
cp .env.example .env

# Edit .env with your development credentials
# Key settings for development:
# - Use H2 database (in-memory)
# - Use Razorpay test credentials
# - Use any valid email for testing

# Install dependencies
mvn clean install

# Run tests
mvn test

# Start development server
mvn spring-boot:run
# Backend now available at: http://localhost:8080
```

### Frontend Setup

```bash
cd ecommerce-frontend

# Copy environment template
cp .env.example .env.local

# Install dependencies
npm install

# Start development server
npm run dev
# Frontend now available at: http://localhost:5173
```

### Verify Setup

```bash
# Test backend API
curl http://localhost:8080/api/products

# Test frontend
# Open http://localhost:5173 in browser
```

---

## 📐 Code Style & Standards

### Java Code Style

**Naming Conventions**:
```java
// Classes: PascalCase
public class ProductController { }
public class ProductService { }

// Methods: camelCase
public List<Product> getAllProducts() { }
public void updateProduct(Product product) { }

// Constants: UPPER_CASE
public static final int MAX_RESULTS = 100;

// Variables: camelCase
private String userEmail;
private int productId;
```

**Formatting Rules**:
```java
// Use 4 spaces for indentation
// Max line length: 100 characters
// Opening braces on same line

public class ExampleClass {
    
    // Private fields first
    private String field1;
    private int field2;
    
    // Constructors
    public ExampleClass() { }
    
    // Public methods
    public void publicMethod() { }
    
    // Private/Helper methods
    private void privateMethod() { }
}
```

**Annotations Best Practices**:
```java
// Use Spring annotations properly
@RestController
@RequestMapping("/api/products")
@RequiredArgsConstructor  // For dependency injection
public class ProductController {
    
    private final ProductService productService;
    
    @GetMapping
    @PreAuthorize("hasRole('USER')")  // Authorization when needed
    public ResponseEntity<List<ProductDTO>> getAllProducts() {
        return ResponseEntity.ok(productService.getAllProducts());
    }
}
```

### JavaScript/React Code Style

**Naming Conventions**:
```javascript
// Components: PascalCase
export function ProductCard({ product }) { }
export const ProductCard = ({ product }) => { }

// Regular functions: camelCase
function handleProductClick() { }
const handleProductClick = () => { }

// Constants: UPPER_CASE
const API_BASE_URL = 'http://localhost:8080/api';

// Variables: camelCase
const productName = 'iPhone';
let cartItems = [];
```

**Component Structure**:
```jsx
// 1. Imports at top
import React, { useState, useEffect } from 'react';
import { useAuth } from '../context/AuthContext';
import api from '../services/api';

// 2. Component function
export function ProductCard({ product, onAddToCart }) {
    // 3. State hooks
    const [quantity, setQuantity] = useState(1);
    const [loading, setLoading] = useState(false);
    
    // 4. Context hooks
    const { user, token } = useAuth();
    
    // 5. Effects
    useEffect(() => {
        // Initialize component
    }, []);
    
    // 6. Handlers
    const handleAddToCart = () => {
        // Handle click
    };
    
    // 7. Render
    return (
        <div className="product-card">
            {/* JSX content */}
        </div>
    );
}
```

---

## 📝 Commit Guidelines

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type

- **feat**: A new feature
- **fix**: A bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, semicolons, etc.)
- **refactor**: Code refactoring (no feature/fix)
- **perf**: Performance improvements
- **test**: Adding tests
- **chore**: Build process, dependencies, tooling

### Examples

**Good Commit Messages**:
```bash
feat(auth): add JWT token refresh functionality
fix(cart): prevent duplicate items when adding to cart
docs(api): add Razorpay payment API documentation
refactor(product): simplify search query logic
test(auth): add unit tests for login service
```

**Bad Commit Messages**:
```bash
# Too vague
fixed stuff
updated code
minor changes

# Too long
feat: implement the new feature for adding products which includes validation and also handles errors

# Missing scope
add payment processing feature
```

### Commit Size

- Keep commits focused and atomic
- One feature per commit (if possible)
- Don't mix refactoring and feature changes
- Test each commit independently

---

## 🔄 Pull Request Process

### Before Creating PR

1. **Update your branch**:
```bash
git fetch upstream
git rebase upstream/develop
```

2. **Create feature branch**:
```bash
git checkout -b feature/my-feature
```

3. **Make changes and commit**:
```bash
git add .
git commit -m "feat(component): add my feature"
```

4. **Push to your fork**:
```bash
git push origin feature/my-feature
```

### Creating PR on GitHub

1. Go to original repository
2. Click "Pull Requests" tab
3. Click "New Pull Request"
4. Select base: `develop` | compare: `your-fork/feature/my-feature`
5. Fill PR template with details

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking)
- [ ] New feature (non-breaking)
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #123

## Testing Done
- [ ] Unit tests created/updated
- [ ] Integration tests passed
- [ ] Manual testing completed

## Screenshots (if applicable)
<!-- Add screenshots for UI changes -->

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex logic
- [ ] Tests passed locally
- [ ] No new warnings generated
```

### PR Review Process

**What Reviewers Check**:
- ✅ Code quality and style
- ✅ Tests are comprehensive
- ✅ Documentation is updated
- ✅ No breaking changes
- ✅ Performance implications
- ✅ Security concerns

**Address Feedback**:
```bash
# Make requested changes
# Add and commit
git add .
git commit -m "refactor: address review feedback"

# Push updated commits
git push origin feature/my-feature
# Don't create new PR, it auto-updates
```

---

## 🧪 Testing Requirements

### Unit Tests Required

Every new feature must include unit tests:

```java
@SpringBootTest
public class ProductServiceTest {
    
    @MockBean
    private ProductRepository productRepository;
    
    @Autowired
    private ProductService productService;
    
    @Test
    public void testSearchProducts_Success() {
        // Arrange
        List<Product> expectedProducts = Arrays.asList(
            new Product("Test Product", 1000)
        );
        when(productRepository.findByNameContainingIgnoreCase("Test"))
            .thenReturn(expectedProducts);
        
        // Act
        List<Product> result = productService.searchProducts("Test");
        
        // Assert
        assertEquals(1, result.size());
        assertEquals("Test Product", result.get(0).getName());
    }
    
    @Test
    public void testSearchProducts_EmptyKeyword() {
        // Should throw exception
        assertThrows(IllegalArgumentException.class, 
            () -> productService.searchProducts(""));
    }
}
```

### Integration Tests

For API endpoints:

```java
@SpringBootTest
@AutoConfigureMockMvc
public class ProductControllerTest {
    
    @Autowired
    private MockMvc mockMvc;
    
    @Test
    public void testGetProducts() throws Exception {
        mockMvc.perform(get("/api/products"))
            .andExpect(status().isOk())
            .andExpect(jsonPath("$.success").value(true));
    }
}
```

### Running Tests

```bash
# Run all tests
mvn test

# Run specific test class
mvn test -Dtest=ProductServiceTest

# Run tests with coverage
mvn test jacoco:report
```

### Test Coverage

- Minimum 70% code coverage required
- Aim for 80%+ coverage
- Critical paths must have 100% coverage

---

## 📚 Documentation Requirements

### Code Documentation

**JavaDoc for Public Methods**:
```java
/**
 * Searches for products by keyword.
 *
 * @param keyword the search keyword (required, min length 1)
 * @return list of products matching the keyword
 * @throws IllegalArgumentException if keyword is empty
 * @see ProductRepository#findByNameContainingIgnoreCase(String)
 */
public List<Product> searchProducts(String keyword) {
    if (keyword == null || keyword.trim().isEmpty()) {
        throw new IllegalArgumentException("Keyword cannot be empty");
    }
    return productRepository.findByNameContainingIgnoreCase(keyword);
}
```

**Inline Comments for Complex Logic**:
```java
// Only comments explaining WHY, not WHAT
// Verify Razorpay signature to prevent payment fraud
String message = orderId + "|" + paymentId;
String generatedSignature = generateHmacSHA256(message, apiSecret);
boolean isValid = generatedSignature.equals(providedSignature);
```

### Documentation Files

**Update README.md if**:
- Adding new feature
- Changing setup process
- Adding new dependency
- Changing API endpoint

**Update API documentation**:
- Every new endpoint
- Every endpoint change
- New error codes

**Update CHANGELOG**:
- List all changes made
- Note breaking changes

---

## 🆘 Common Issues

### Git Issues

**Issue**: "Permission denied (publickey)" when pushing
```bash
# Solution: Check SSH keys
ssh -T git@github.com

# If fails, add SSH key
# Follow: https://docs.github.com/en/authentication/connecting-to-github-with-ssh
```

**Issue**: "Your branch is behind 'upstream/develop' by X commits"
```bash
# Solution: Rebase
git fetch upstream
git rebase upstream/develop
```

### Java Build Issues

**Issue**: "Cannot resolve symbol" in IDE
```bash
# Solution: Reload Maven
mvn clean install
# In IDE: Maven → Reload Projects
```

**Issue**: Port 8080 already in use
```bash
# Solution: Kill process or use different port
# Windows:
netstat -ano | findstr :8080
taskkill /PID <PID> /F

# Linux/macOS:
lsof -i :8080
kill -9 <PID>

# Or change port in application.properties
server.port=8081
```

### React Issues

**Issue**: "npm ERR! code EACCES: permission denied"
```bash
# Solution: Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
export PATH=~/.npm-global/bin:$PATH
```

**Issue**: Blank page or 404 in development
```bash
# Solution: Ensure both servers running
# Terminal 1: npm run dev (from ecommerce-frontend)
# Terminal 2: mvn spring-boot:run (from backend)
# Check proxy setting in vite.config.js
```

---

## 📞 Need Help?

- **GitHub Issues**: Report bugs and request features
- **Discussions**: Ask questions and share ideas
- **Email**: For sensitive issues

---

## 🎉 Thank You!

Your contributions help make this project better. Thank you for your time and effort!

---

**Last Updated**: March 2024  
**Maintained By**: Praveen Kumar
