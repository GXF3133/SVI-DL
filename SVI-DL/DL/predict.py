import os
import time

import torch
from torchvision import transforms
import numpy as np
from PIL import Image

from model import UNet


def time_synchronized():
    torch.cuda.synchronize() if torch.cuda.is_available() else None
    return time.time()


def main():
    classes = 1  # exclude background
    weights_path = "./weights/best_model.pth"
    folder_path = './dataset/test/images'
    assert os.path.exists(weights_path), f"weights {weights_path} not found."
    mean = (0.709, 0.381, 0.224)
    std = (0.127, 0.079, 0.043)
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    print("using {} device.".format(device))
    model = UNet(in_channels=3, num_classes=classes+1, base_c=32)
    model.load_state_dict(torch.load(weights_path, map_location='cpu')['model'])
    model.to(device)

    for filename in os.listdir(folder_path):
        file_path = os.path.join(folder_path, filename)
        # load image
        original_img = Image.open(file_path).convert('RGB')
        # from pil image to tensor and normalize
        data_transform = transforms.Compose([transforms.ToTensor(),
                                             transforms.Normalize(mean=mean, std=std)])
        img = data_transform(original_img)
        # expand batch dimension
        img = torch.unsqueeze(img, dim=0)
        model.eval()
        with torch.no_grad():
            # init model
            img_height, img_width = img.shape[-2:]
            init_img = torch.zeros((1, 3, img_height, img_width), device=device)
            model(init_img)
            t_start = time_synchronized()
            output = model(img.to(device))
            t_end = time_synchronized()
            print("inference time: {}".format(t_end - t_start))
            prediction = output['out'].argmax(1).squeeze(0)
            prediction = prediction.to("cpu").numpy().astype(np.uint8)
            # Change the values in the area corresponding to 1 to 255 for easier display
            prediction[prediction == 1] = 255
            mask = Image.fromarray(prediction)
            mask.save('./result/'+os.path.splitext(os.path.basename(file_path))[0]+'_.png')
if __name__ == '__main__':
    main()
