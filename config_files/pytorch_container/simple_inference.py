import torch
import torchvision.models as models
import torchvision.transforms as transforms
from PIL import Image
import urllib.request
import sys

if len(sys.argv) < 2:
    print("Usage: python3 simple_inference.py <image_url>")
    sys.exit(1)

image_url = sys.argv[1]
#image_url = "https://raw.githubusercontent.com/pytorch/hub/master/images/dog.jpg"

# Simple example: classify one image using ResNet18
print("Loading model...")
model = models.resnet18(weights=models.ResNet18_Weights.DEFAULT)
model.eval().cuda()

# Download example image
urllib.request.urlretrieve(image_url, "input_image.jpg")

# Preprocess
transform = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor(),
    transforms.Normalize(mean=[0.485, 0.456, 0.406],
                         std=[0.229, 0.224, 0.225]),
])

img = Image.open("input_image.jpg").convert("RGB")
input_tensor = transform(img).unsqueeze(0).cuda()

# Run inference
with torch.no_grad():
    output = model(input_tensor)
    pred_idx = output.argmax().item()

# Load labels
labels_url = "https://raw.githubusercontent.com/pytorch/hub/master/imagenet_classes.txt"
labels = urllib.request.urlopen(labels_url).read().decode("utf-8").splitlines()

print(f"Predicted class: {labels[pred_idx]}")
