>----------------------- Ahmed Mobasher Khan -------------------------<
>---------------------- mobasherswl@yahoo.com ------------------------<

A sample project of "Graphics Editor" in Assembly language.

This is project was developed during university time while studying Assembly language course. It's very basic in nature but at that time it was huge achievement for me. :)

Features:
	1. 640x480 mode
	2. 16 color support
	3. Draws vertical & horizontal lines of variable size
	4. Draws rectangle of variable size with different boundary & 		   fill color
	5. Individual objects can be moved
	6. Individual objects can be deleted
	7. Whole paint area can be cleared
	8. Decent visual interface

_______________________________________________________________________

Design:

- The blue bar at the top is the title bar containing a red box at the top right corner. Click this box to close the program.

- The left gray area is the non-client area containing tools. The first palette of 16 colors is used to select the desired color for drawing. The next to color boxes show selected colors and allow colors to be selected if first clicked by left mouse button. The left box shows current fill color for rectangles only while the right box gives the color for lines and boundary color for rectangles.

- The next 4 boxes are used to select the desired shape. The first box is for horizontal line, 2nd for vertical line, 3rd for rectangle and the 4th blank box can be selected to remove a specific or all objects.

_______________________________________________________________________

How to use:

- To draw press left mouse button & move it according to the dimensions of the object to be drawn and then release the left mouse button.

- To move objects, place mouse cursor on the object, press left mouse button and move it to the next location and release the left mouse button. The object will be moved.

- To delete a specific object, left click the blank box in the tools palette and then left click on the object to delete.

- To delete all objects at once, left click the blank box and right click anywhere. If you right click by mistake the whole drawing area will be deleted.
