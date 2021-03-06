#' Create a dashboard sidebar.
#'
#' A dashboard sidebar typically contains a \code{\link{sidebarMenu}}, although
#' it may also contain a \code{\link{sidebarSearchForm}}, or other Shiny inputs.
#'
#' @param ... Items to put in the sidebar.
#' @param disable If \code{TRUE}, the sidebar will be disabled.
#'
#' @seealso \code{\link{sidebarMenu}}
#'
#' @examples
#' \donttest{
#' header <- dashboardHeader()
#'
#' sidebar <- dashboardSidebar(
#'   sidebarUserPanel("User Name"),
#'   sidebarSearchForm(label = "Enter a number", "searchText", "searchButton"),
#'   sidebarMenu(
#'     menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
#'     menuItem("Widgets", icon = icon("th"), tabName = "widgets", badgeLabel = "new",
#'              badgeColor = "green"),
#'     menuItem("Charts", icon = icon("bar-chart-o"),
#'       menuSubItem("Sub-item 1", tabName = "subitem1"),
#'       menuSubItem("Sub-item 2", tabName = "subitem2")
#'     )
#'   )
#' )
#'
#' body <- dashboardBody(
#'   tabItems(
#'     tabItem("dashboard",
#'       div(p("Dashboard tab content"))
#'     ),
#'     tabItem("widgets",
#'       "Widgets tab content"
#'     ),
#'     tabItem("subitem1",
#'       "Sub-item 1 tab content"
#'     ),
#'     tabItem("subitem2",
#'       "Sub-item 2 tab content"
#'     )
#'   )
#' )
#'
#' shinyApp(
#'   ui = dashboardPage(header, sidebar, body),
#'   server = function(input, output) { }
#' )
#' }
#' @export
dashboardSidebar <- function(..., disable = FALSE) {
  tags$section(
    class = "sidebar",
    `data-disable` = if(disable) 1 else NULL,
    list(...)
  )
}

#' A panel displaying user information in a sidebar
#'
#' @param name Name of the user.
#'
#' @family sidebar items
#'
#' @seealso \code{\link{dashboardSidebar}} for example usage.
#'
#' @export
sidebarUserPanel <- function(name) {
  div(class = "user-panel",
    div(class = "pull-left image",
      img(src = "foo.png", class = "img-circle", alt = "User Image")
    ),
    div(class = "pull-left info",
      p(paste("Hello,", name)),
      a(href = "#", shiny::icon("circle", class = "text-success"), "Online")
    )
  )
}

#' Create a search form to place in a sidebar
#'
#' A search form consists of a text input field and a search button.
#'
#' @param textId Shiny input ID for the text input box.
#' @param buttonId Shiny input ID for the search button (which functions like an
#'   \code{\link[shiny]{actionButton}}).
#' @param label Text label to display inside the search box.
#' @param icon An icon tag, created by \code{\link[shiny]{icon}}.
#'
#' @family sidebar items
#'
#' @seealso \code{\link{dashboardSidebar}} for example usage.
#'
#' @export
sidebarSearchForm <- function(textId, buttonId, label = "Search...",
                              icon = shiny::icon("search")) {
  tags$form(class = "sidebar-form",
    div(class = "input-group",
      tags$input(id = textId, type = "text", class = "form-control",
        placeholder = label
      ),
      span(class = "input-group-btn",
        tags$button(id = buttonId, type = "button",
          class = "btn btn-flat action-button",
          icon
        )
      )
    )
  )
}

#' Create a dashboard sidebar menu and menu items.
#'
#' A \code{dashboardSidebar} can contain a \code{sidebarMenu}. A
#' \code{sidebarMenu} contains \code{menuItem}s, and they can in turn contain
#' \code{menuSubItem}s.
#'
#' Menu items (and similarly, sub-items) should have a value for either
#' \code{href} or \code{tabName}; otherwise the item would do nothing. If it has
#' a value for \code{href}, then the item will simply be a link to that value.
#'
#' If a \code{menuItem} has a non-NULL \code{tabName}, then the \code{menuItem}
#' will behave like a tab -- in other words, clicking on the \code{menuItem}
#' will bring a corresponding \code{tabItem} to the front, similar to a
#' \code{\link[shiny]{tabPanel}}. One important difference between a
#' \code{menuItem} and a \code{tabPanel} is that, for a \code{menuItem}, you
#' must also supply a corresponding \code{tabItem} with the same value for
#' \code{tabName}, whereas for a \code{tabPanel}, no \code{tabName} is needed.
#' (This is because the structure of a \code{tabPanel} is such that the tab name
#' can be automatically generated.) Sub-items are also able to activate
#' \code{tabItem}s.
#'
#' Menu items (but not sub-items) also may have an optional badge. A badge is a
#' colored oval containing text.
#'
#' @param text Text to show for the menu item.
#' @param icon An icon tag, created by \code{\link[shiny]{icon}}.
#' @param badgeLabel A label for an optional badge. Usually a number or a short
#'   word like "new".
#' @param badgeColor A color for the badge. Valid colors are listed in
#'   \link{validColors}.
#' @param href An link address. Not compatible with \code{tabName}.
#' @param tabName The name of a tab that this menu item will activate. Not
#'   compatible with \code{href}.
#' @param newtab If \code{href} is supplied, should the link open in a new tab?
#' @param ... For menu items, this may consist of \code{\link{menuSubItem}}s.
#'
#' @family sidebar items
#'
#' @seealso \code{\link{dashboardSidebar}} for example usage.
#'
#' @export
sidebarMenu <- function(...) {
  items <- list(...)

  # Make sure the items are li tags
  lapply(items, tagAssert, type = "li")

  tags$ul(class = "sidebar-menu",
    ...
  )
}

#' @rdname sidebarMenu
#' @export
menuItem <- function(text, ..., icon = NULL, badgeLabel = NULL, badgeColor = "green",
                     tabName = NULL, href = NULL, newtab = TRUE) {
  subItems <- list(...)
  lapply(subItems, tagAssert, type = "li")

  if (!is.null(icon)) tagAssert(icon, type = "i")
  if (!is.null(href) + !is.null(tabName) + (length(subItems) > 0) != 1 ) {
    stop("Must have either href, tabName, or sub-items (contained in ...).")
  }

  if (!is.null(badgeLabel) && length(subItems) != 0) {
    stop("Can't have both badge and subItems")
  }
  validateColor(badgeColor)

  # If there's a tabName, set up the correct href and <a> target
  isTabItem <- FALSE
  target <- NULL
  if (!is.null(tabName)) {
    isTabItem <- TRUE
    href <- paste0("#shiny-tab-", tabName)
  } else if (is.null(href)) {
    href <- "#"
  } else {
    # If supplied href, set up <a> tag's target
    if (newtab)
      target <- "_blank"
  }

  # Generate badge if needed
  if (!is.null(badgeLabel)) {
    badgeTag <- tags$small(
      class = paste0("badge pull-right bg-", badgeColor),
      badgeLabel
    )
  } else {
    badgeTag <- NULL
  }

  # If no subitems, return a pretty simple tag object
  if (length(subItems) == 0) {
    return(
      tags$li(
        a(href = href,
          `data-toggle` = if (isTabItem) "tab",
          target = target,
          icon,
          span(text),
          badgeTag
        )
      )
    )
  }

  tags$li(class = "treeview",
    a(href = href,
      icon,
      span(text),
      shiny::icon("angle-left", class = "pull-right")
    ),
    tags$ul(class = "treeview-menu",
      subItems
    )
  )
}

#' @rdname sidebarMenu
#' @export
menuSubItem <- function(text, tabName = NULL, href = NULL, newtab = TRUE) {

  if (!is.null(href) && !is.null(tabName)) {
    stop("Can't specify both href and tabName")
  }

  # If there's a tabName, set up the correct href
  isTabItem <- FALSE
  target <- NULL
  if (!is.null(tabName)) {
    isTabItem <- TRUE
    href <- paste0("#shiny-tab-", tabName)
  } else if (is.null(href)) {
    href <- "#"
  } else {
    # If supplied href, set up <a> tag's target
    if (newtab)
      target <- "_blank"
  }


  tags$li(
    a(href = href,
      `data-toggle` = if (isTabItem) "tab",
      target = target,
      shiny::icon("angle-double-right"),
      text
    )
  )
}
