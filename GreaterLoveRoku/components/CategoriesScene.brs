' All Categories Scene Logic - Figma Design
' Grid-based category browsing with 5 rows of content

sub init()
    print "CategoriesScene init - Figma Design"
    
    ' Get UI elements
    m.navMenu = m.top.findNode("navMenu")
    m.row1 = m.top.findNode("row1")
    m.row2 = m.top.findNode("row2")
    m.row3 = m.top.findNode("row3")
    m.row4 = m.top.findNode("row4")
    m.row5 = m.top.findNode("row5")
    m.backButton = m.top.findNode("backButton")
    m.focusIndicator = m.top.findNode("focusIndicator")

    ' Set initial focus to first row
    m.row1.setFocus(true)
    m.currentRow = m.row1
    m.currentRowIndex = 1

    ' Setup navigation
    setupNavigation()
    setupCategories()

    ' Setup observers
    m.row1.observeField("itemSelected", "onCategorySelected")
    m.row2.observeField("itemSelected", "onCategorySelected")
    m.row3.observeField("itemSelected", "onCategorySelected")
    m.row4.observeField("itemSelected", "onCategorySelected")
    m.row5.observeField("itemSelected", "onCategorySelected")
    m.backButton.observeField("itemSelected", "onBackButtonSelected")
end sub

sub setupNavigation()
    ' Setup top navigation menu
    navItems = []
    
    ' HOME
    homeItem = createObject("roSGNode", "ContentNode")
    homeItem.title = "HOME"
    homeItem.contentType = "home"
    navItems.append(homeItem)
    
    ' ABOUT US
    aboutItem = createObject("roSGNode", "ContentNode")
    aboutItem.title = "ABOUT US"
    aboutItem.contentType = "about"
    navItems.append(aboutItem)
    
    ' ALL CATEGORIES (highlighted)
    categoriesItem = createObject("roSGNode", "ContentNode")
    categoriesItem.title = "ALL CATEGORIES"
    categoriesItem.contentType = "categories"
    categoriesItem.highlighted = true
    navItems.append(categoriesItem)
    
    ' Set navigation content
    navContent = createObject("roSGNode", "ContentNode")
    navContent.appendChild(navItems)
    m.navMenu.content = navContent
end sub

sub setupCategories()
    ' Setup all category rows with sample data
    setupCategoryRow(m.row1, [
        {title: "MINISTRY NOW", subtitle: "All", image: "pkg:/images/show_placeholder.png"},
        {title: "JONI TABLE TALK", subtitle: "Original", image: "pkg:/images/show_placeholder.png"},
        {title: "REBECCA WEISS", subtitle: "Live TV", image: "pkg:/images/show_placeholder.png"},
        {title: "GROWING UP", subtitle: "Movies", image: "pkg:/images/show_placeholder.png"}
    ])
    
    setupCategoryRow(m.row2, [
        {title: "MARCUS & JONI", subtitle: "Web Series", image: "pkg:/images/show_placeholder.png"},
        {title: "JONI", subtitle: "Original", image: "pkg:/images/show_placeholder.png"},
        {title: "REBECCA WEISS", subtitle: "Live TV", image: "pkg:/images/show_placeholder.png"},
        {title: "GROWING UP", subtitle: "Movies", image: "pkg:/images/show_placeholder.png"}
    ])
    
    setupCategoryRow(m.row3, [
        {title: "MINISTRY NOW", subtitle: "All", image: "pkg:/images/show_placeholder.png"},
        {title: "JONI TABLE TALK", subtitle: "Original", image: "pkg:/images/show_placeholder.png"},
        {title: "REBECCA WEISS", subtitle: "Live TV", image: "pkg:/images/show_placeholder.png"},
        {title: "GROWING UP", subtitle: "Movies", image: "pkg:/images/show_placeholder.png"}
    ])
    
    setupCategoryRow(m.row4, [
        {title: "MARCUS & JONI", subtitle: "Web Series", image: "pkg:/images/show_placeholder.png"},
        {title: "JONI", subtitle: "Original", image: "pkg:/images/show_placeholder.png"},
        {title: "REBECCA WEISS", subtitle: "Live TV", image: "pkg:/images/show_placeholder.png"},
        {title: "GROWING UP", subtitle: "Movies", image: "pkg:/images/show_placeholder.png"}
    ])
    
    setupCategoryRow(m.row5, [
        {title: "MINISTRY NOW", subtitle: "All", image: "pkg:/images/show_placeholder.png"},
        {title: "JONI TABLE TALK", subtitle: "Original", image: "pkg:/images/show_placeholder.png"},
        {title: "REBECCA WEISS", subtitle: "Live TV", image: "pkg:/images/show_placeholder.png"},
        {title: "GROWING UP", subtitle: "Movies", image: "pkg:/images/show_placeholder.png"}
    ])
end sub

sub setupCategoryRow(rowList as object, categoryData as object)
    categoryItems = []
    
    for each category in categoryData
        categoryItem = createObject("roSGNode", "ContentNode")
        categoryItem.title = category.title
        categoryItem.subtitle = category.subtitle
        categoryItem.hdPosterUrl = category.image
        categoryItem.contentType = "category"
        categoryItems.append(categoryItem)
    end for
    
    categoryContent = createObject("roSGNode", "ContentNode")
    categoryContent.appendChild(categoryItems)
    rowList.content = categoryContent
end sub

sub onCategorySelected(event as object)
    selectedItem = m.currentRow.content.getChild(event.getData())
    print "Category selected:"; selectedItem.title
    
    ' Show category content or navigate to shows
    showDialog("Category", "Selected: " + selectedItem.title + " (" + selectedItem.subtitle + ")")
end sub

sub onBackButtonSelected(event as object)
    print "Back button selected"
    ' Navigate back to home
    m.top.getParent().callFunc("showHomeScene")
end sub

sub showDialog(title as string, message as string)
    dialog = createObject("roSGNode", "Dialog")
    dialog.title = title
    dialog.message = message
    dialog.buttons = ["OK"]
    m.top.appendChild(dialog)
    dialog.observeField("buttonSelected", "onDialogButton")
    dialog.setFocus(true)
end sub

sub onDialogButton(event as object)
    ' Close dialog
    event.getRoSGNode().getParent().removeChild(event.getRoSGNode())
    m.currentRow.setFocus(true)
end sub
