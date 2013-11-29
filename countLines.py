#!/usr/bin/python
# -*- coding: utf-8 -*-
import time
import os
from datetime import datetime
from datetime import timedelta

def line_count(filename):
    '''Count file's lines neglect '\n' '''
    count = 0
    for line in open(filename): 
        if(line!='\n'):count+=1
    print filename,count
    return count

def file_count(dirname,filter_types=[]):
    '''Count the files in a directory includes its subfolder's files
       You can set the filter types to count specific types of file'''
    count=0
    filter_is_on=False
    if filter_types!=[]: filter_is_on=True
    for item in os.listdir(dirname):
        abs_item=os.path.join(dirname,item)
        #print item
        if os.path.isdir(abs_item):
            #Iteration for dir
            count+=file_count(abs_item,filter_types)
        elif os.path.isfile(abs_item):           
            if filter_is_on:
                #Get file's extension name
                extname=os.path.splitext(abs_item)[1]
                if extname in filter_types:
                    count+=1
            else:
                count+=1
    return count
    
def file_changed_count(dirname,base_time,filter_types=[]):
    '''Count the files in a directory includes its subfolder's files.
       You can set the filter types to count specific types of file.
       And set basetiem to count the file if it's modified time is over base_time'''
    count=0
    filter_is_on=False
    if filter_types!=[]: filter_is_on=True
    for item in os.listdir(dirname):
        abs_item=os.path.join(dirname,item)
        if os.path.isdir(abs_item):
            #Iteration for dir
            count+=file_count(abs_item,filter_types)
        elif os.path.isfile(abs_item):
            mt=datetime.fromtimestamp(os.stat(abs_item)[8])
            if mt>base_time:
                if filter_is_on:
                    #Get file's extension name
                    extname=os.path.splitext(abs_item)[1]
                    if extname in filter_types:
                        count+=1
                else:
                    count+=1
    return count

def count_all_lines(dirname,filter_types=[]):
    '''Count all files' lines of specific types in one directory includes its
       subdirectories.'''
    count=0
    filter_is_on=False
    if filter_types!=[]: filter_is_on=True
   
    for item in os.listdir(dirname):
        abs_item=os.path.join(dirname,item)
        #List all item in dir
        #Join item and dir to make the path of files
        if os.path.isdir(abs_item):
            #If path is a dir,recurse this function
            count+=count_all_lines(abs_item,filter_types)
        elif os.path.isfile(abs_item):
            if filter_is_on:
                #Get file's extension name
                extname=os.path.splitext(abs_item)[1]
                if extname in filter_types:
                    #print extname
                    count+=line_count(abs_item)
            else:
                count+=line_count(abs_item)
    return count

def join_files(dirname,filter_types=[],ignor_files=[]):
    '''join all files' lines of specific types in one directory includes its
       subdirectories.'''
    newFile = "";
    filter_is_on=False
    if filter_types!=[]: filter_is_on=True
   
    for item in os.listdir(dirname):
        abs_item=os.path.join(dirname,item)
        #List all item in dir
        #Join item and dir to make the path of files
        ignorThisFile = False
        for ignorItem in ignor_files:
            if os.path == ignorItem:
                ignorThisFile = True
                break
        if ignorThisFile:
            continue
        
        if os.path.isdir(abs_item):
            #If path is a dir,recurse this function
            newFile+=join_files(abs_item,filter_types)
        elif os.path.isfile(abs_item):
            if filter_is_on:
                #Get file's extension name
                extname=os.path.splitext(abs_item)[1]
                if extname in filter_types:
                    #print extname
                    newFile+=join_lines(abs_item)
            else:
                newFile+=join_lines(abs_item)
    return newFile

def join_lines(filename):
    """list all lines in file and join them
    """
    fileLines=""
    for line in open(filename): 
        if(line!='\n'):fileLines+=line
    return fileLines

if __name__=='__main__':

    #srcdir=r"/home/giyya/server/game/"
    srcdir=r"./"
    #Set file's filter types
    cs_type=['.cs']
    pas_type=['.pas']
    filter_types=['.coffee','.less','.html','.css','.js']
    filter_types=['.coffee','.less','.html']
    filter_types=['.coffee']
    #filter_types=['.js']
    ignor_files=['',]

    #lineNum=count_all_lines(srcdir)
    fileNum=file_count(srcdir,filter_types)
    lineNum=count_all_lines(srcdir,filter_types)
    # newFileData = join_files(srcdir,filter_types,ignor_files)
    # newFileDir = r"/home/giyya/server/newJsFile.js"
    # newFile = open(newFileDir,"w")
    # newFile.write(newFileData)
    # newFile.close()
    
    print "target Path:"
    print srcdir
    print "file types:"
    print filter_types
    print "\nfile num:"
    print fileNum
    print "line num:"
    print lineNum
