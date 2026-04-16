// Loading Animation
document.addEventListener('DOMContentLoaded', function() {
    // Show loading for 2 seconds then fade out
    setTimeout(function() {
        const loadingOverlay = document.getElementById('loading-overlay');
        const container = document.querySelector('.container');
        
        if (loadingOverlay) {
            loadingOverlay.classList.add('hidden');
        }
        
        if (container) {
            container.classList.add('visible');
        }
    }, 2000);
});

// Form Validation
function validateForm(formId) {
    const form = document.getElementById(formId);
    if (!form) return true;
    
    let isValid = true;
    const requiredFields = form.querySelectorAll('[required]');
    
    requiredFields.forEach(field => {
        if (!field.value.trim()) {
            isValid = false;
            field.classList.add('error');
            
            // Add error message if not exists
            let errorMsg = field.parentElement.querySelector('.error-message');
            if (!errorMsg) {
                errorMsg = document.createElement('div');
                errorMsg.className = 'error-message';
                errorMsg.innerHTML = '<i class="fas fa-exclamation-circle"></i> This field is required';
                field.parentElement.appendChild(errorMsg);
            }
        } else {
            field.classList.remove('error');
            const errorMsg = field.parentElement.querySelector('.error-message');
            if (errorMsg) {
                errorMsg.remove();
            }
        }
    });
    
    // Password match validation
    const password = document.getElementById('id_preferred_password');
    const confirm = document.getElementById('id_confirm_password');
    
    if (password && confirm && password.value !== confirm.value) {
        isValid = false;
        confirm.classList.add('error');
        
        let errorMsg = confirm.parentElement.querySelector('.error-message');
        if (!errorMsg) {
            errorMsg = document.createElement('div');
            errorMsg.className = 'error-message';
            errorMsg.innerHTML = '<i class="fas fa-exclamation-circle"></i> Passwords do not match';
            confirm.parentElement.appendChild(errorMsg);
        }
    }
    
    return isValid;
}

// File Upload Preview
function handleFileUpload(input) {
    const fileUpload = input.closest('.file-upload');
    const preview = fileUpload.querySelector('.file-preview');
    const content = fileUpload.querySelector('.file-upload-content');
    
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        
        reader.onload = function(e) {
            preview.src = e.target.result;
            preview.style.display = 'block';
            content.style.display = 'none';
        }
        
        reader.readAsDataURL(input.files[0]);
    }
}

// Tab Switching
function switchTab(tabName) {
    window.location.href = `/register/${tabName}/`;
}

// Form Submission with Loading State
function handleFormSubmit(event) {
    const submitBtn = event.target.querySelector('button[type="submit"]');
    if (submitBtn) {
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';
    }
    return true;
}

// Admin Actions
function approveSubmission(submissionId, type) {
    if (confirm('Are you sure you want to approve this submission?')) {
        document.getElementById(`approve-form-${submissionId}`).submit();
    }
}

function rejectSubmission(submissionId, type) {
    const reason = prompt('Please enter reason for rejection:');
    if (reason) {
        document.getElementById(`reject-reason-${submissionId}`).value = reason;
        document.getElementById(`reject-form-${submissionId}`).submit();
    }
}

// Filter Submissions
function filterSubmissions() {
    const status = document.getElementById('status-filter').value;
    const type = document.getElementById('type-filter').value;
    const search = document.getElementById('search-filter').value;
    
    const url = new URL(window.location.href);
    url.searchParams.set('status', status);
    url.searchParams.set('type', type);
    url.searchParams.set('search', search);
    
    window.location.href = url.toString();
}

// Debounce for search
let searchTimeout;
function debounceSearch() {
    clearTimeout(searchTimeout);
    searchTimeout = setTimeout(filterSubmissions, 500);
}

// Initialize on page load
document.addEventListener('DOMContentLoaded', function() {
    // File upload handlers
    document.querySelectorAll('input[type="file"]').forEach(input => {
        input.addEventListener('change', function() {
            handleFileUpload(this);
        });
    });
    
    // Form validation
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
        form.addEventListener('submit', function(event) {
            if (!validateForm(this.id)) {
                event.preventDefault();
            } else {
                handleFormSubmit(event);
            }
        });
    });
    
    // Search debounce
    const searchInput = document.getElementById('search-filter');
    if (searchInput) {
        searchInput.addEventListener('input', debounceSearch);
    }
});
