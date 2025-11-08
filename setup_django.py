#!/usr/bin/env python
"""
Django Backend Setup Script
Run this to create the complete Django backend structure
"""

import os
import subprocess
import sys

def run_command(cmd, cwd=None):
    """Run a command and return the result."""
    print(f"\n▶ Running: {cmd}")
    result = subprocess.run(cmd, shell=True, cwd=cwd, capture_output=True, text=True)
    if result.returncode != 0:
        print(f"❌ Error: {result.stderr}")
        return False
    print(f"✅ Success: {result.stdout}")
    return True

def main():
    backend_dir = r"C:\Programs\Flutter_Projects\Local_medicine_av\local_medicine\backend"
    
    print("=" * 70)
    print("DJANGO BACKEND SETUP")
    print("=" * 70)
    
    # Step 1: Install dependencies
    print("\n[1/6] Installing Django and dependencies...")
    packages = [
        "Django==4.2.7",
        "djangorestframework==3.14.0",
        "djangorestframework-simplejwt==5.3.0",
        "django-cors-headers==4.3.0",
        "django-redis==5.4.0",
        "python-decouple==3.8",
        "argon2-cffi==23.1.0",
        "drf-spectacular==0.26.5"
    ]
    
    if not run_command(f"pip install {' '.join(packages)} --quiet"):
        print("Failed to install dependencies")
        return
    
    # Step 2: Create Django project
    print("\n[2/6] Creating Django project...")
    if not run_command("django-admin startproject config .", cwd=backend_dir):
        print("Failed to create Django project")
        return
    
    # Step 3: Create apps
    print("\n[3/6] Creating Django apps...")
    apps = ['accounts', 'medicines', 'stores', 'inventory', 'requests_app']
    for app in apps:
        if not run_command(f"python manage.py startapp {app}", cwd=backend_dir):
            print(f"Failed to create app: {app}")
            return
    
    print("\n✅ Django backend structure created successfully!")
    print("\nNext steps:")
    print("1. Review backend/config/settings.py")
    print("2. Run: python manage.py makemigrations")
    print("3. Run: python manage.py migrate")  
    print("4. Run: python manage.py createsuperuser")
    print("5. Run: python manage.py runserver 0.0.0.0:8000")

if __name__ == "__main__":
    main()
