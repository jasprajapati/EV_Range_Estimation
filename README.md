# EV Range Estimation – Battery Modeling Project

This project estimates the driving range of an electric vehicle (EV) by modeling its **battery pack behavior**, **pack current profile**, **state of charge (SOC)**, and **energy consumption** over a specific drive cycle. Developed as part of the **Advanced Energy Storage Systems** course at the University of Windsor, this simulation aims to predict how different load conditions affect the EV's effective range.

> Course: ECE – Advanced Energy Storage Systems  
> Professor: Dr. Balakumar Balasingam  
> Author: Jas Prajapati (110147267)

---

## ⚡ Project Objective

To simulate and analyze the impact of varying duty cycles and current draw on the **battery state of charge (SOC)** and calculate the **maximum achievable range** of an EV under different driving conditions. The simulation provides insight into how energy storage systems perform in real-world vehicle operations and supports design optimization for EV range extension.

---

## 🧰 Tools & Methodology

- **MATLAB** used for plotting and simulation
- Modeled:
  - **Duty Cycle P(t)** – Power demand over time  
  - **Battery Pack Current I(t)** – Derived from power profile  
  - **SOC(t)** – Using Coulomb counting or energy balance method
- Final **range estimation** derived from SOC depletion under applied power/current load

---

## 📈 Outputs

- **Duty Cycle P(t):** Simulated power profile of the vehicle under dynamic driving
- **Pack Current I(t):** Resultant current required from the battery pack
- **State of Charge (SOC):** Decrease over time based on energy drawn
- **Estimated Range:** Distance traveled before SOC reaches minimum threshold

---

## 🧠 Key Concepts Demonstrated

- Battery modeling and simulation
- Energy consumption profiling
- Range estimation techniques
- Time-series current analysis
- SOC calculation using MATLAB
- Power systems in electric vehicles

---


