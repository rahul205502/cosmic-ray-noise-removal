# Cosmic Ray Noise Removal using Fuzzy Logic and Adaptive Filtering

## Overview

Cosmic ray hits frequently corrupt astronomical images captured by satellites and telescopes. These artifacts appear as bright spikes or streaks caused by high-energy particles striking imaging sensors.

This project implements a **hybrid intelligent image restoration system** in MATLAB that detects and removes cosmic ray artifacts using:

* Temporal difference analysis
* Spatial feature extraction
* Fuzzy logic based classification
* Adaptive filtering (NLMS and RLS)

The algorithm first detects potential cosmic ray pixels using a **Fuzzy Inference System (FIS)** and then selectively applies **adaptive filtering techniques** to restore corrupted pixels.

---

## Features

* Image registration for temporal alignment
* Multi-feature cosmic ray detection
* Fuzzy inference based probability estimation
* NLMS adaptive filtering
* RLS filtering for high probability cosmic ray pixels
* Gaussian smoothing for final refinement
* Performance evaluation using **PSNR** and **MSE**

---

## Methodology

The algorithm consists of five main stages:

### 1. Image Preprocessing

* Load two temporal images
* Convert RGB to grayscale if necessary
* Perform intensity-based image registration

### 2. Feature Extraction

Four features are computed to identify cosmic ray artifacts:

| Feature             | Description                                  |
| ------------------- | -------------------------------------------- |
| Temporal Difference | Difference between two time-separated images |
| Gradient Magnitude  | Edge strength in image                       |
| Laplacian           | High-frequency spike detection               |
| Local Variance      | Pixel intensity variation                    |

All features are normalized between **0 and 1**.

---

### 3. Fuzzy Logic Based Detection

A **Mamdani Fuzzy Inference System** evaluates the probability of a pixel being affected by cosmic rays.

#### Inputs

* Diff
* Grad
* Lap
* Var

Each input uses three membership functions:

* Low
* Medium
* High

#### Output

Cosmic Ray Probability

Example rules:

* Diff = High AND Lap = High → Cosmic Ray = High
* Grad = High AND Var = High → Cosmic Ray = High
* Diff = Medium AND Lap = High → Cosmic Ray = Medium
* Diff = Low → Cosmic Ray = Low

---

### 4. Adaptive Filtering

Two adaptive filters are applied:

#### NLMS Filter

* Applied to the entire image
* Step size controlled by fuzzy cosmic ray probability
* Reduces moderate noise

#### RLS Filter

* Applied only when cosmic ray probability > 0.6
* Removes strong impulse artifacts
* Faster convergence than LMS

---

### 5. Final Smoothing

A Gaussian filter is applied to remove residual artifacts and smooth the restored image.

---

## Performance Metrics

Two metrics are used for evaluation:

**Peak Signal-to-Noise Ratio (PSNR)**

PSNR measures reconstruction quality.

**Mean Squared Error (MSE)**

Measures average squared difference between restored image and reference.

---

## Output

The program generates four outputs:

1. Original corrupted image
2. Cosmic ray probability map
3. Image after adaptive filtering
4. Final restored image

Example visualization:

```
Original Image
CR Probability Map
Adaptive Filter Output
Final Restored Image
```

---

## Requirements

Software:

* MATLAB R2020 or later

Toolboxes required:

* Image Processing Toolbox
* Fuzzy Logic Toolbox

---

## How to Run

1. Clone the repository

```bash
git clone https://github.com/yourusername/cosmic-ray-noise-removal-fuzzy-adaptive-filtering
```

2. Open MATLAB

3. Run the main script

```matlab
cosmic_ray_removal.m
```

---

## Example Output

The algorithm produces:

* Restored astronomical image
* Cosmic ray detection probability map
* PSNR and MSE values printed in MATLAB console

Example:

```
PSNR: 34.82 dB
MSE: 0.000412
```

---

## Applications

* Satellite imaging
* Astronomical observations
* Space telescope data cleaning
* CCD sensor noise removal
* Scientific image restoration

---

## Future Improvements

* Deep learning based cosmic ray detection
* GPU acceleration
* Real-time satellite image processing
* Multi-frame cosmic ray detection
* Adaptive fuzzy rule optimization

---

## Author

Rahul M

Electronics and Communication Engineering
Image Processing | FPGA | Signal Processing | Space Systems
