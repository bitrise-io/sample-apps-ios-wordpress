// Blog Details contents:
//
// + (No Title)
// | View Site
// | Stats
// | View Admin
//
// + Publish
// | Blog Posts
// | Pages
// | Comments
//
// + Configuration
// | Edit Site

#import "BlogDetailsViewController.h"
#import "Blog+Jetpack.h"
#import "EditSiteViewController.h"
#import "PagesViewController.h"
#import "CommentsViewController.h"
#import "ThemeBrowserViewController.h"
#import "MediaBrowserViewController.h"
#import "StatsViewController.h"
#import "WPWebViewController.h"
#import "WPTableViewCell.h"
#import "ContextManager.h"
#import "BlogService.h"
#import "WPTableViewSectionHeaderView.h"
#import "UIImageView+Gravatar.h"

const typedef enum {
    BlogDetailsRowViewSite = 0,
    BlogDetailsRowStats = 1,
    BlogDetailsRowViewAdmin = 2,
    BlogDetailsRowBlogPosts = 0,
    BlogDetailsRowPages = 1,
    BlogDetailsRowComments = 2,
    BlogDetailsRowEditSite = 0
} BlogDetailsRow;

const typedef enum {
    TableViewSectionGeneralType = 0,
    TableViewSectionPublishType,
    TableViewSectionConfigurationType
} TableSectionContentType;

static NSString *const BlogDetailsCellIdentifier = @"BlogDetailsCell";
NSString * const WPBlogDetailsRestorationID = @"WPBlogDetailsID";
NSString * const WPBlogDetailsBlogKey = @"WPBlogDetailsBlogKey";

static CGFloat const BDVCTableViewHeaderHeight = 160.0;
static CGFloat const BDVCBlavatarOffset = 10.0;
static CGFloat const BDVCBlavatarWidth = 120.0;
static CGFloat const BDVCBlavatarHeight = 120.0;

@interface BlogDetailsViewController ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *gravatarView;

@end

@implementation BlogDetailsViewController
@synthesize blog = _blog;

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder
{
    NSString *blogID = [coder decodeObjectForKey:WPBlogDetailsBlogKey];
    if (!blogID) {
        return nil;
    }

    NSManagedObjectContext *context = [[ContextManager sharedInstance] mainContext];
    NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:blogID]];
    if (!objectID) {
        return nil;
    }

    NSError *error = nil;
    Blog *restoredBlog = (Blog *)[context existingObjectWithID:objectID error:&error];
    if (error || !restoredBlog) {
        return nil;
    }

    BlogDetailsViewController *viewController = [[self alloc] initWithStyle:UITableViewStyleGrouped];
    viewController.blog = restoredBlog;

    return viewController;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.restorationIdentifier = WPBlogDetailsRestorationID;
        self.restorationClass = [self class];
    }
    return self;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:[[self.blog.objectID URIRepresentation] absoluteString] forKey:WPBlogDetailsBlogKey];
    [super encodeRestorableStateWithCoder:coder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [WPStyleGuide configureColorsForView:self.view andTableView:self.tableView];
    [self.tableView registerClass:[WPTableViewCell class] forCellReuseIdentifier:BlogDetailsCellIdentifier];

    NSManagedObjectContext *context = [[ContextManager sharedInstance] mainContext];
    BlogService *blogService = [[BlogService alloc] initWithManagedObjectContext:context];

    [blogService syncBlog:_blog success:nil failure:nil];

    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, CGRectGetWidth(self.view.bounds), BDVCTableViewHeaderHeight)];
    self.tableView.tableHeaderView = self.headerView;

    float x = (self.headerView.frame.size.width - BDVCBlavatarWidth) / 2.0;
    self.gravatarView = [[UIImageView alloc] initWithFrame:CGRectMake(x, BDVCBlavatarOffset, BDVCBlavatarWidth, BDVCBlavatarHeight)];
    [self.gravatarView setImageWithBlavatarUrl:self.blog.blavatarUrl isWPcom:self.blog.isWPcom];
    [self.headerView addSubview:self.gravatarView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)setBlog:(Blog *)blog
{
    _blog = blog;
    self.title = blog.blogName;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == TableViewSectionGeneralType) {
        return 3;
    } else if (section == TableViewSectionPublishType) {
        return 3;
    } else if (section == TableViewSectionConfigurationType) {
        return 1;
    }

    return 0;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == TableViewSectionGeneralType) {
        switch (indexPath.row) {
            case BlogDetailsRowViewSite:
                cell.textLabel.text = NSLocalizedString(@"View Site", nil);
                cell.imageView.image = [UIImage imageNamed:@"icon-menu-viewsite"];
                break;
            case BlogDetailsRowStats:
                cell.textLabel.text = NSLocalizedString(@"Stats", nil);
                cell.imageView.image = [UIImage imageNamed:@"icon-menu-stats"];
                break;
            case BlogDetailsRowViewAdmin:
                cell.textLabel.text = NSLocalizedString(@"View Admin", nil);
                cell.imageView.image = [UIImage imageNamed:@"icon-menu-viewadmin"];
                break;
            default:
                break;
        }
    } else if (indexPath.section == TableViewSectionPublishType) {
        switch (indexPath.row) {
            case BlogDetailsRowBlogPosts:
                cell.textLabel.text = NSLocalizedString(@"Blog Posts", nil);
                cell.imageView.image = [UIImage imageNamed:@"icon-menu-posts"];
                break;
            case BlogDetailsRowPages:
                cell.textLabel.text = NSLocalizedString(@"Pages", nil);
                cell.imageView.image = [UIImage imageNamed:@"icon-menu-pages"];
                break;
            case BlogDetailsRowComments:
                cell.textLabel.text = NSLocalizedString(@"Comments", nil);
                cell.imageView.image = [UIImage imageNamed:@"icon-menu-comments"];
                NSUInteger numberOfPendingComments = [self.blog numberOfPendingComments];
                if (numberOfPendingComments > 0) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", numberOfPendingComments];
                }
                break;
            default:
                break;
        }
    } else if (indexPath.section == TableViewSectionConfigurationType) {
        if (indexPath.row == BlogDetailsRowEditSite) {
            cell.textLabel.text = NSLocalizedString(@"Edit Site", nil);
            cell.imageView.image = [UIImage imageNamed:@"icon-menu-settings"];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:BlogDetailsCellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [self configureCell:cell atIndexPath:indexPath];
    [WPStyleGuide configureTableViewCell:cell];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if (indexPath.section == TableViewSectionConfigurationType && indexPath.row == BlogDetailsRowEditSite) {
        EditSiteViewController *editSiteViewController = [[EditSiteViewController alloc] initWithBlog:self.blog];
        [self.navigationController pushViewController:editSiteViewController animated:YES];
    }

    Class controllerClass;
    if (indexPath.section == TableViewSectionGeneralType) {
        switch (indexPath.row) {
            case BlogDetailsRowViewSite:
                [self showViewSiteForBlog:self.blog];
                break;
            case BlogDetailsRowStats:
                [WPAnalytics track:WPAnalyticsStatStatsAccessed];
                controllerClass =  [StatsViewController class];
                break;
            case BlogDetailsRowViewAdmin:
                [self showViewAdminForBlog:self.blog];
                break;
            default:
                break;
        }
    } else if (indexPath.section == TableViewSectionPublishType) {
        switch (indexPath.row) {
            case BlogDetailsRowBlogPosts:
                [WPAnalytics track:WPAnalyticsStatOpenedPosts];
                controllerClass = [PostsViewController class];
                break;
            case BlogDetailsRowPages:
                [WPAnalytics track:WPAnalyticsStatOpenedPages];
                controllerClass = [PagesViewController class];
                break;
            case BlogDetailsRowComments:
                [WPAnalytics track:WPAnalyticsStatOpenedComments];
                controllerClass = [CommentsViewController class];
                break;
            default:
                break;
        }
    }

    // Check if the controller is already on the screen
    if ([self.navigationController.visibleViewController isMemberOfClass:controllerClass]) {
        if ([self.navigationController.visibleViewController respondsToSelector:@selector(setBlog:)]) {
            [self.navigationController.visibleViewController performSelector:@selector(setBlog:) withObject:self.blog];
        }
        [self.navigationController popToRootViewControllerAnimated:NO];

        return;
    }

    UIViewController *viewController = (UIViewController *)[[controllerClass alloc] init];
    viewController.restorationIdentifier = NSStringFromClass(controllerClass);
    viewController.restorationClass = controllerClass;
    if ([viewController respondsToSelector:@selector(setBlog:)]) {
        [viewController performSelector:@selector(setBlog:) withObject:self.blog];
        [self.navigationController pushViewController:viewController animated:YES];
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString *title = [self tableView:self.tableView titleForHeaderInSection:section];
    return [WPTableViewSectionHeaderView heightForTitle:title andWidth:CGRectGetWidth(self.view.bounds)];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *title = [self tableView:self.tableView titleForHeaderInSection:section];
    if (title.length > 0) {
        WPTableViewSectionHeaderView *header = [[WPTableViewSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 0)];
        header.title = title;
        return header;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *headingTitle = nil;
    if (section == TableViewSectionPublishType) {
        headingTitle = NSLocalizedString(@"Publish", @"");
    } else if (section == TableViewSectionConfigurationType) {
        headingTitle = NSLocalizedString(@"Configuration", @"");
    }

    return headingTitle;
}

#pragma mark - Private methods
- (void)showViewSiteForBlog:(Blog *)blog
{
    [WPAnalytics track:WPAnalyticsStatOpenedViewSite];

    NSString *blogURL = blog.homeURL;
    if (![blogURL hasPrefix:@"http"]) {
        blogURL = [NSString stringWithFormat:@"http://%@", blogURL];
    } else if ([blog isWPcom] && [blog.url rangeOfString:@"wordpress.com"].location == NSNotFound) {
        blogURL = [blog.xmlrpc stringByReplacingOccurrencesOfString:@"xmlrpc.php" withString:@""];
    }

    // Check if the same site already loaded
    if ([self.navigationController.visibleViewController isMemberOfClass:[WPWebViewController class]] &&
        [((WPWebViewController*)self.navigationController.visibleViewController).url.absoluteString isEqual:blogURL]) {
        // Do nothing
    } else {
        WPWebViewController *webViewController = [[WPWebViewController alloc] init];
        [webViewController setUrl:[NSURL URLWithString:blogURL]];
        if ([blog isPrivate]) {
            [webViewController setUsername:blog.username];
            [webViewController setPassword:blog.password];
            [webViewController setWpLoginURL:[NSURL URLWithString:blog.loginUrl]];
        }
        [self.navigationController pushViewController:webViewController animated:YES];
    }
    return;
}

- (void)showViewAdminForBlog:(Blog *)blog
{
    [WPAnalytics track:WPAnalyticsStatOpenedViewAdmin];

    NSString *dashboardUrl = [blog.xmlrpc stringByReplacingOccurrencesOfString:@"xmlrpc.php" withString:@"wp-admin/"];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:dashboardUrl]];
}

@end
