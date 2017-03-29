#!/usr/bin/env python3

# embedding_in_qt5.py --- Simple Qt5 application embedding matplotlib canvases
#
# Copyright (C) 2005 Florent Rougon
#               2006 Darren Dale
#               2015 Jens H Nielsen
#
# This file is an example program for matplotlib. It may be used and
# modified with no restriction; raw copies as well as modified versions
# may be distributed without limitation.

from __future__ import unicode_literals
import sys
import os
import random
import h5py
import matplotlib
import matplotlib.pyplot as plt
import numpy as np
# Make sure that we are using QT5
#matplotlib.use('Qt5Agg')
from PyQt5 import QtCore, QtWidgets

from numpy import arange, sin, pi
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure

progname = os.path.basename(sys.argv[0])
progversion = "0.1"

t_speed=1

filename="data.jld"
f = h5py.File(filename, 'r')
Ex= f["Ex"][()]
Hy= f["Hy"][()]
#save("data.jld", "Ex", Ex, "Hy", Hy, "dt", dt, "dz", dz, "G", G, "x", x, "xSteps", xSteps, "timeSteps", timeSteps,"left_bord_ind",left_bord_ind,"right_bord_ind",right_bord_ind)
dt=f["dt"][()]
dz=f["dz"][()]
x=f["x"][()]
t=f["t"][()]
signal=f["signal"][()]
signal_pos=f["signal_pos"][()]
timeSteps=f["timeSteps"][()]
xSteps=f["xSteps"][()]
left_bord_ind=f["left_bord_ind"][()]
right_bord_ind=f["right_bord_ind"][()]

f.close()

#n=timeSteps
n=0

class MyMplCanvas(FigureCanvas):
    """Ultimately, this is a QWidget (as well as a FigureCanvasAgg, etc.)."""

    def __init__(self, parent=None, width=5, height=4, dpi=100):
        fig = Figure(figsize=(width, height), dpi=dpi)
        self.axes = fig.add_subplot(111)
        # We want the axes cleared every time plot() is called
        self.axes.hold(False)

        self.compute_initial_figure()

        #
        FigureCanvas.__init__(self, fig)
        self.setParent(parent)

        FigureCanvas.setSizePolicy(self,
                                   QtWidgets.QSizePolicy.Expanding,
                                   QtWidgets.QSizePolicy.Expanding)
        FigureCanvas.updateGeometry(self)

    def compute_initial_figure(self):
        pass


class MyStaticMplCanvas(MyMplCanvas):
    """Simple canvas with a sine plot."""
    def __init__(self, *args, **kwargs):
        MyMplCanvas.__init__(self, *args, **kwargs)
        timer = QtCore.QTimer(self)
        timer.timeout.connect(self.update_figure)
        timer.start(0.1)

    def compute_initial_figure(self):
        self.axes.plot(t*10**6,signal)        
        self.axes.hold(True)
        self.axes.plot([t[0]*10**6,t[0]*10**6],[-10,10],color='r')
        self.axes.hold(False)
        self.axes.set_xlim(t[0]*10**6,t[-1]*10**6)
        self.axes.set_ylim(-1.5,1.5)
        self.axes.grid(True)
        
    def update_figure(self):
        global n
        if n>timeSteps-1:
            n=0
        self.axes.plot(t*10**6,signal)        
        self.axes.hold(True)
        self.axes.plot([t[n]*10**6,t[n]*10**6],[-10,10],color='r')
        self.axes.hold(False)
        self.axes.set_xlim(t[0]*10**6,t[-1]*10**6)
        self.axes.set_ylim(-1.5,1.5)
        self.axes.grid(True)
        self.draw()


class MyDynamicMplCanvas(MyMplCanvas):
    """A canvas that updates itself every second with a new plot."""

    def __init__(self, *args, **kwargs):
        MyMplCanvas.__init__(self, *args, **kwargs)
        timer = QtCore.QTimer(self)
        timer.timeout.connect(self.update_figure)
        timer.start(0.1)

    def compute_initial_figure(self):
        self.axes.plot(x,Hy[:,1]*120*np.pi,color='m')
        self.axes.plot(x,Ex[:,1],color='b',lw=2)
        self.axes.set_xlim(x[0],x[-1])
        #self.axes.set_ylim(-1.5,1.5)
        self.axes.set_ylim(-2.,2.)
        self.axes.grid(True)

    def update_figure(self):
        global n
        if n>timeSteps-1:
            n=0
        self.axes.plot(x,Hy[:,n]*120*np.pi,color='m')        
        self.axes.hold(True)
        self.axes.plot(x,Ex[:,n],color='b',lw=2)
        self.axes.plot([x[signal_pos],x[signal_pos]],[signal[n],signal[n]],'ro')
        
        self.axes.plot([x[left_bord_ind-1],x[left_bord_ind-1]],[-10,10],color="g")
        self.axes.plot([x[right_bord_ind-1],x[right_bord_ind-1]],[-10,10],color="g")
        self.axes.hold(False)
        n+=t_speed
        #print(n)
        self.axes.set_xlim(x[0],x[-1])
        #self.axes.set_ylim(-1.5,1.5)
        self.axes.set_ylim(-2.,2.)
        self.axes.grid(True)
        self.draw()


class ApplicationWindow(QtWidgets.QMainWindow):
    def __init__(self):
        QtWidgets.QMainWindow.__init__(self)
        self.setAttribute(QtCore.Qt.WA_DeleteOnClose)
        self.setWindowTitle("application main window")

        self.file_menu = QtWidgets.QMenu('&File', self)
        self.file_menu.addAction('&Quit', self.fileQuit,
                                 QtCore.Qt.CTRL + QtCore.Qt.Key_Q)
        self.menuBar().addMenu(self.file_menu)

        self.help_menu = QtWidgets.QMenu('&Help', self)
        self.menuBar().addSeparator()
        self.menuBar().addMenu(self.help_menu)

        self.help_menu.addAction('&About', self.about)

        self.main_widget = QtWidgets.QWidget(self)

        l = QtWidgets.QVBoxLayout(self.main_widget)
        sc = MyStaticMplCanvas(self.main_widget, width=5, height=4, dpi=100)
        dc = MyDynamicMplCanvas(self.main_widget, width=5, height=4, dpi=100)
        l.addWidget(sc)
        l.addWidget(dc)

        self.main_widget.setFocus()
        self.setCentralWidget(self.main_widget)

        self.statusBar().showMessage("All hail matplotlib!", 2000)

    def fileQuit(self):
        self.close()

    def closeEvent(self, ce):
        self.fileQuit()

    def about(self):
        QtWidgets.QMessageBox.about(self, "About",
                                    """embedding_in_qt5.py example
Copyright 2005 Florent Rougon, 2006 Darren Dale, 2015 Jens H Nielsen

This program is a simple example of a Qt5 application embedding matplotlib
canvases.

It may be used and modified with no restriction; raw copies as well as
modified versions may be distributed without limitation.

This is modified from the embedding in qt4 example to show the difference
between qt4 and qt5"""
                                )




qApp = QtWidgets.QApplication(sys.argv)

aw = ApplicationWindow()
aw.setWindowTitle("%s" % progname)
aw.show()
sys.exit(qApp.exec_())
#qApp.exec_()
