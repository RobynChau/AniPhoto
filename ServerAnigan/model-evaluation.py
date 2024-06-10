import numpy as np
import matplotlib.pyplot as plt
from helpers.animegan import generate_anime_image

source_img_path = "https://firebasestorage.googleapis.com/v0/b/ios-entertainment-photography.appspot.com/o/806187AA-DC94-40AD-BF52-8C20538B8A32-200102%2Fraw%2F1717311301.jpg?alt=media&token=64cab261-cf17-4e7d-9313-954b26f0ed87"
num_tests = 10
response_times = []

for _ in range(num_tests):
    _, response_time = generate_anime_image(source_img_path)
    response_times.append(response_time)

# Generate times for x-axis
times = np.arange(1, num_tests + 1)

# Plot the results
plt.figure(figsize=(10, 6))
plt.plot(times, response_times, marker='o', linestyle='-', color='b')
plt.xlabel('Times')
plt.ylabel('Response Times (seconds)')
plt.title('Model Response Times Over Multiple Runs')
plt.grid(True)
plt.savefig('response_times_chart.png')
plt.show()
plt.savefig('response_times_chart.png')
print("Chart saved as response_times_chart.png")