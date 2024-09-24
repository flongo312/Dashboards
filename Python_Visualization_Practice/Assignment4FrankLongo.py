#############################################################
# Import Necessary Packages
#############################################################

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
from math import floor, ceil

#############################################################
# Question 1 Read in Cars csv
#############################################################

cars = pd.read_csv("/Users/frank/Desktop/Classes/QMB_6304_Data_Visualization/Datasets/CarSales.csv")

#############################################################
# Question 2 Scatter Plots
#############################################################

average_data = cars.groupby('Make').agg({
    'SalePrice': 'mean',
    'CostPrice': 'mean',
    'LaborCost': 'mean',
    'SpareParts': 'mean'
}).reset_index()

# Calculating the overall averages
overall_avg_cost = cars['CostPrice'].mean()
overall_avg_sale_price = cars['SalePrice'].mean()
overall_avg_labor_cost = cars['LaborCost'].mean()
overall_avg_spare_parts_cost = cars['SpareParts'].mean()

# Create a 2x2 matrix of subplots
fig, ((ax1, ax2), (ax3, ax4)) = plt.subplots(2, 2, figsize=(13, 8))

# Plot 1
ax1.scatter(average_data['CostPrice'], average_data['SalePrice'], color='blue', label='Make')
ax1.axhline(y=overall_avg_sale_price, linestyle='--', linewidth=0.5, color='black')
ax1.axvline(x=overall_avg_cost, linestyle='--', linewidth=0.5, color='black')
for i, txt in enumerate(average_data['Make']):
    ax1.annotate(txt, (average_data['CostPrice'].iloc[i], average_data['SalePrice'].iloc[i]),
                 color='red', size=8, ha='left', va='center', alpha=0.7)
ax1.set_title('Average Sale Price vs. Average Cost', fontweight='bold') 
ax1.set_xlabel('Average Cost', fontstyle='italic', fontweight='bold') 
ax1.set_ylabel('Average Sales Price', fontstyle='italic', fontweight='bold')  
ax1.set_xticks(np.arange(0, 80000, 20000))
ax1.set_xticklabels([f'{x//1000}K' for x in np.arange(0, 80000, 20000)])  
ax1.set_yticks(np.arange(0, 120000, 40000))
ax1.set_yticklabels([f'{y//1000}K' for y in np.arange(0, 120000, 40000)])  
ax1.grid(color='black', linestyle='-', linewidth=0.1)

# Plot 2
ax2.scatter(average_data['LaborCost'], average_data['SalePrice'], color='blue', marker='s', edgecolors='black')
ax2.axhline(y=overall_avg_sale_price, linestyle='--', linewidth=0.5, color='black')
ax2.axvline(x=overall_avg_labor_cost, linestyle='--', linewidth=0.5, color='black')
for i, txt in enumerate(average_data['Make']):
    ax2.annotate(txt, (average_data['LaborCost'].iloc[i], average_data['SalePrice'].iloc[i]),
                 color='red', size=8, ha='left', va='center', alpha=0.7)
ax2.set_title('Average Sale Price vs. Average Labor Cost', fontweight='bold')  
ax2.set_xlabel('Average Labor Cost', fontstyle='italic', fontweight='bold')  
ax2.set_ylabel('Average Sales Price', fontstyle='italic', fontweight='bold')  
ax2.set_xlim(0.8 * min(average_data['LaborCost']), 1.2 * max(average_data['LaborCost']))
ax2.set_yticks(np.arange(0, 120000, 40000))
ax2.set_yticklabels([f'{y//1000}K' for y in np.arange(0, 120000, 40000)]) 
ax2.grid(color='black', linestyle='-', linewidth=0.1)

# Plot 3
ax3.scatter(average_data['SpareParts'], average_data['SalePrice'], color='blue', marker='^', edgecolors='black')
ax3.axhline(y=overall_avg_sale_price, linestyle='--', linewidth=0.5, color='black')
ax3.axvline(x=overall_avg_spare_parts_cost, linestyle='--', linewidth=0.5, color='black')
for i, txt in enumerate(average_data['Make']):
    ax3.annotate(txt, (average_data['SpareParts'].iloc[i], average_data['SalePrice'].iloc[i]),
                 color='red', size=8, ha='left', va='center', alpha=0.7)
ax3.set_title('Average Sale Price vs. Average Spare Parts Cost', fontweight='bold')  
ax3.set_xlabel('Average Parts Cost', fontstyle='italic', fontweight='bold')  
ax3.set_ylabel('Average Sales Price', fontstyle='italic', fontweight='bold')  
ax3.set_xlim(0.8 * min(average_data['SpareParts']), 1.2 * max(average_data['SpareParts']))
ax3.set_yticks(np.arange(0, 120000, 40000))
ax3.set_yticklabels([f'{y//1000}K' for y in np.arange(0, 120000, 40000)]) 
ax3.grid(color='black', linestyle='-', linewidth=0.1)

# Plot 4
ax4.scatter(average_data['SpareParts'], average_data['LaborCost'], color='blue', marker='o', edgecolors='red')
ax4.axhline(y=overall_avg_labor_cost, linestyle='--', linewidth=0.5, color='black')
ax4.axvline(x=overall_avg_spare_parts_cost, linestyle='--', linewidth=0.5, color='black')
for i, txt in enumerate(average_data['Make']):
    ax4.annotate(txt, (average_data['SpareParts'].iloc[i], average_data['LaborCost'].iloc[i]),
                 color='red', size=8, ha='left', va='center', alpha=0.7)

# Regression calculation
x_values = np.linspace(0.8 * min(average_data['SpareParts']), 1.2 * max(average_data['SpareParts']), 100)
regression_line = np.poly1d(np.polyfit(average_data['SpareParts'], average_data['LaborCost'], 1))
ax4.plot(x_values, regression_line(x_values), color='black', linestyle='-', linewidth=2)

ax4.set_title('Average Labor Cost vs. Average Spare Parts Cost', fontweight='bold')  
ax4.set_xlabel('Average Parts Cost', fontstyle='italic', fontweight='bold')
ax4.set_ylabel('Average Labor Cost', fontstyle='italic', fontweight='bold')
ax4.set_xlim(0.8 * min(average_data['SpareParts']), 1.2 * max(average_data['SpareParts']))
ax4.set_ylim(0.8 * min(average_data['LaborCost']), 1.2 * max(average_data['LaborCost']))
ax4.grid(color='black', linestyle='-', linewidth=0.1)

plt.tight_layout()
plt.show()

#############################################################
# Question 3 - Horizontal Bar Plot
#############################################################

# Create a figure and axis for the plot
fig, ax = plt.subplots(figsize=(13, 8))

# Find out how many bars (car makes) will be in the plot
num_bars = len(average_data['Make'])

# Generate different colors for each bar in the plot
colors = plt.cm.tab20c(np.linspace(0, 1, num_bars))

# Create a horizontal bar plot
bars = ax.barh(average_data['Make'], average_data['SalePrice'], color=colors)

# Set the title of the plot
ax.set_title("Average Sale Price by Car Make", fontsize=14, fontweight="bold")

# Customize the appearance of the plot
ax.grid(False) 
border_color = 'black'  

# Set the color of each side of the plot frame
for spine in ['top', 'right', 'bottom', 'left']:
    ax.spines[spine].set_color(border_color)

# Customize x-axis ticks appearance
ax.tick_params(axis='x', which='both', bottom=True, top=False, labelbottom=True, colors=border_color)

# Set x-axis ticks and labels in thousands
ax.set_xticks(np.arange(0, 120001, 10000))
ax.set_xticklabels([f'{x//1000}K' for x in np.arange(0, 120001, 10000)], color=border_color)

# Reverse the order of car makes to show the highest at the top and the lowest at the bottom
ax.invert_yaxis()

# Display the plot
plt.show()

#############################################################
# Question 4 - Grouped Bar Plot
#############################################################

# Set the visual style of the plot to have a white grid background for better visualization
sns.set(style="whitegrid")

# Define specific colors for different vehicle types: Blue, Green, and Red
colors = ["#4C72B0", "#55A868", "#C44E52"]

# Create a count plot to show the number of each vehicle type in each country
sns.countplot(
    data=cars,              
    x='CountryName',        
    hue='VehicleType',      
    palette=colors,         
    dodge=True,            
    edgecolor='black'       
)

# Set a title for the plot
plt.title("Distribution of Vehicle Types by Country", fontsize=14, fontweight="bold")

# Remove x and y axis labels for cleaner visualization
plt.xlabel(None)
plt.ylabel(None)  

# Display the plot
plt.show()

#############################################################
# Question 5 - Pie Chart
#############################################################

# Calculate total sales for each type of vehicle
sales_by_type = cars.groupby('VehicleType')['SalePrice'].agg(total_sales='sum').reset_index()

# Define colors to use in the pie chart
colors = sns.color_palette('Set3') 

# Create a pie chart to visualize the total sales by vehicle type
fig, ax = plt.subplots(figsize=(8, 8)) 

# Plot the pie chart with vehicle types and percentages inside the slices
wedges, texts, autotexts = ax.pie(sales_by_type['total_sales'],
                                  labels=sales_by_type['VehicleType'],
                                  autopct='%1.1f%%',  
                                  startangle=0,
                                  colors=colors,
                                  pctdistance=0.85,  
                                  wedgeprops=dict(edgecolor='black')) 

# Set the aspect ratio of the pie chart to be equal
ax.axis('equal')

# Set font size for pie chart labels
for text, autotext in zip(texts, autotexts):
    text.set_fontsize(10)
    autotext.set_fontsize(10)

# Set title for the plot
plt.title("Total Sales by Vehicle Type", fontsize=12, fontweight="bold")

# Display the plot
plt.show()

#############################################################
# Question 6 - Histogram
#############################################################

# Number of bins for the histogram
num_bins = 15

# Creating a plot area with a specific size
plt.figure(figsize=(13, 8))

# Plotting a histogram to show the distribution of car costs
plt.hist(
    cars['CostPrice'],  
    bins=num_bins,  
    color='#4e79a7', 
    edgecolor='black', 
    alpha=0.8 
)

# Adding individual car data points on the cost price scale (rug plot)
jittered_x = cars['CostPrice'] + np.random.uniform(low=-2000, high=2000, size=len(cars))
sns.rugplot(x=jittered_x, height=-0.02, clip_on=False, color='#e15759', alpha=0.7)

# Adding a title and labels to the plot
plt.title("Distribution of Car Costs", fontsize=16, fontweight="bold")  
plt.xlabel("Cost in Thousands (USD)", fontsize=12, fontweight="bold")  
plt.ylabel("Frequency", fontsize=12, fontweight="bold") 

# Customizing x-axis for better readability (adjusting font size)
plt.xticks(fontsize=10)

# Setting y-axis limits and adding horizontal grid lines for better visualization
plt.ylim(0, 120)  
plt.grid(axis='y', linestyle='--', alpha=0.5)  

# Setting the background color of the plot area
plt.gca().set_facecolor('#f9f9f9')  

# Displaying the plot
plt.show()

#############################################################
# Question 7 - Density Curves
#############################################################

# Calculate the profit for each car: Sale Price minus Cost Price
cars['Profit'] = cars['SalePrice'] - cars['CostPrice']

# Create a plot with a width of 10 units and height of 6 units
plt.figure(figsize=(13, 8))

# Create a plot to show the distribution of profit using a filled density plot
sns.kdeplot(data=cars, x='Profit', fill=True, color='#808080', alpha=0.5)

# Add small red tick marks along the x-axis to show individual data points
sns.rugplot(data=cars, x='Profit', color='#e74c3c', alpha=0.5, height=-0.02, clip_on=False)

# Set the title and labels for the plot
plt.title("Profit Distribution", fontsize=16, fontweight="bold", pad=20)  
plt.xlabel("Profit", fontsize=12, fontweight="bold", labelpad=12)  
plt.ylabel("", fontsize=12)  

# Adjust the range and labels on the x-axis for better display
min_profit = floor(min(cars['Profit']) / 40000) * 40000 
max_profit = ceil(max(cars['Profit']) / 40000) * 40000  
plt.xlim(min_profit, max_profit)  

# Set x-axis tick positions and labels in 'K' format without decimals
plt.xticks(
    np.arange(min_profit, max_profit + 1, 40000),
    labels=[f'{int(x/1000)}K' for x in np.arange(min_profit, max_profit + 1, 40000)]
)

# Set light gray background color and add horizontal gridlines for better visualization
plt.gca().set_facecolor('#f9f9f9') 
plt.grid(axis='y', linestyle='--', alpha=0.5) 

# Display the created plot
plt.show()

#############################################################
# Question 8 - Multiple Density Curves
#############################################################

# Calculate the profit for each car by subtracting the cost price from the sale price
cars['Profit'] = cars['SalePrice'] - cars['CostPrice']

# Set the style and color palette for the plot using seaborn
sns.set(style="whitegrid", palette="Set3")

# Create a figure for the plot with specific dimensions (width and height)
plt.figure(figsize=(13, 8))

# Iterate through each unique type of vehicle available in the dataset
for index, vehicle_type in enumerate(cars['VehicleType'].unique()):
    # Create a subset of data for each type of vehicle
    subset_data = cars[cars['VehicleType'] == vehicle_type]
    
# Plot the density curve (KDE) of profit for each vehicle type
# Fill the curve and set varying transparency based on index for better visualization
    sns.kdeplot(data=subset_data, x='Profit', label=vehicle_type, fill=True, alpha=0.5 + 0.1 * index)

# Set the title of the plot to describe the content
plt.title("Profit Density by Car Type", fontsize=16, fontweight="bold")

# Set a label for the x-axis to describe the data being plotted
plt.xlabel("Profit (in $)", fontsize=12)
# Set an empty label for the y-axis to keep the plot clean
plt.ylabel("", fontsize=12)

# Set the limits and ticks for the x-axis based on the range of profit values
min_profit = floor(min(cars['Profit']) / 40000) * 40000  
max_profit = ceil(max(cars['Profit']) / 40000) * 40000  
plt.xlim(min_profit, max_profit)  
plt.xticks(np.arange(min_profit, max_profit + 1, 40000),  
           labels=[f'{x/1000}K' for x in np.arange(min_profit, max_profit + 1, 40000)], 
           fontsize=10)  

# Add a legend to the plot with a title and place it on the left side of the plot
plt.legend(title='Car Type', fontsize=10, loc='upper left')

# Display the plot with the plotted data and labels
plt.show()

#############################################################
# Question 9 - Box Plots
#############################################################

# Set the style and color palette for the plot using seaborn
sns.set(style="whitegrid", palette="Set3")

# Create a figure and axis for the plot
plt.figure(figsize=(13, 8))  

# Generate a box plot showing the distribution of sale prices for different vehicle types
sns.boxplot(data=cars, x='VehicleType', y='SalePrice', palette="Set3") 

# Set the title of the plot in bold
plt.title('Comparison of Sale Prices for Different Vehicle Types', fontsize=14, fontweight="bold") 

# Label the y-axis with Sale Price in bold
plt.ylabel('Sale Price (in $)', fontsize=12, fontweight="bold")  

# Set y-axis ticks and labels in 'K' format without decimals
plt.yticks(np.arange(0, max(cars['SalePrice']) + 40000, 40000),  
           labels=[f'{int(y/1000)}K' for y in np.arange(0, max(cars['SalePrice']) + 40000, 40000)],  
           fontsize=10)  

# Remove the main x-axis label
plt.xlabel(None) 

# Show the plot
plt.show()






