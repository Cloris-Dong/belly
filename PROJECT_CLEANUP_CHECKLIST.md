# Project Cleanup Checklist for Belly App

## 🎯 Goal
Fix duplicate file errors and create a clean, maintainable project structure.

## 📋 Current Issues
- [x] **CRITICAL**: Duplicate `FridgeView.swift` files causing build errors
- [x] Duplicate `AddView.swift` files (different names but same purpose)
- [x] Duplicate `ShoppingView.swift` files (different names but same purpose)
- [x] Inconsistent folder structure
- [x] Need to reorganize for proper MVVM architecture

## 🧹 Cleanup Steps

### Step 1: Remove Duplicate Files
- [ ] **Delete**: `/Belly/Views/FridgeView.swift` (66 lines - simple version)
- [ ] **Delete**: `/Belly/Views/AddView.swift` (129 lines - simple version) 
- [ ] **Delete**: `/Belly/Views/ShoppingView.swift` (219 lines - simple version)
- [ ] **Delete**: Entire `/Belly/Views/` folder (after confirming files are deleted)

### Step 2: Rename for Consistency
- [ ] **Rename**: `/Features/Add/AddItemView.swift` → `/Features/Add/AddView.swift`
- [ ] **Rename**: `/Features/Shopping/ShoppingListView.swift` → `/Features/Shopping/ShoppingView.swift`

### Step 3: Update ContentView References
- [ ] **Update**: `ContentView.swift` to use correct view names:
  - `FridgeView()` → keep as is (Features/Fridge/FridgeView.swift)
  - `AddView()` → update import if needed
  - `ShoppingView()` → update import if needed

### Step 4: Create Proper Folder Structure
- [ ] **Create**: `App/` folder for main app files
- [ ] **Move**: `BellyApp.swift` → `App/BellyApp.swift`
- [ ] **Move**: `ContentView.swift` → `App/ContentView.swift`
- [ ] **Reorganize**: Core Data models into `Core/Data/Models/`
- [ ] **Create**: ViewModels folders for each feature

### Step 5: Update Xcode Project References
- [ ] **Remove**: Old file references from Xcode project
- [ ] **Add**: New file references to Xcode project
- [ ] **Organize**: Groups in Xcode to match folder structure
- [ ] **Test**: Build project to ensure no missing references

## ⚠️ Before You Start
1. **Backup**: Commit current state to git
2. **Compare**: Ensure Features/ files are more complete
3. **Test**: Verify app builds after each step

## 🔍 File Comparison Results
| File | Simple Views/ | Complex Features/ | Keep |
|------|--------------|------------------|------|
| FridgeView | 66 lines | 271 lines | Features ✅ |
| AddView | 129 lines | 380 lines | Features ✅ |
| ShoppingView | 219 lines | 416 lines | Features ✅ |

## ✅ Post-Cleanup Verification
- [ ] App builds without errors
- [ ] All three tabs work correctly
- [ ] Core Data integration functional
- [ ] No duplicate file warnings
- [ ] Xcode project organized properly

## 🚀 Next Steps After Cleanup
1. Extract ViewModels from Views
2. Create proper MVVM separation
3. Add proper error handling
4. Implement proper navigation
5. Add unit tests

---
*Run this checklist step by step to ensure clean project structure.*
