//
//  DPMTableViewController.m
//  DPMusicControllerDemoApp
//
//  Created by Dan Pourhadi on 2/10/13.
//  Copyright (c) 2013 Dan Pourhadi. All rights reserved.
//

#import "DPMTableViewController.h"

@interface DPMTableViewController ()
{
	BOOL loaded;
}

@end

@implementation DPMTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if (!self.tableTitle) {
		self.tableTitle = @"";
	}

	NSArray *titleArray = @[@"Songs", @"Artists", @"Albums", self.tableTitle, @"Queue"];
	
	self.title = [titleArray objectAtIndex:self.tableContentType];
	
	[self reloadList];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:kDPMusicNotificationLibraryLoaded object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadList) name:kDPMusicNotificationPlaylistChanged object:nil];
}

- (void)reloadList
{
	switch (self.tableContentType) {
		case DPMTableViewControllerContentTypeSongs:
			loaded = [[[DPMusicController sharedController] libraryManager] songsLoaded];
			self.items = [[DPMusicController sharedController] indexedSongs];
			break;
		case DPMTableViewControllerContentTypeArtists:
			loaded = [[[DPMusicController sharedController] libraryManager] artistsLoaded];
			self.items = [[DPMusicController sharedController] indexedArtists];
			break;
		case DPMTableViewControllerContentTypeAlbums:
			loaded = [[[DPMusicController sharedController] libraryManager] albumsLoaded];
			self.items = [[DPMusicController sharedController] indexedAlbums];
			
			break;
		case DPMTableViewControllerContentTypeDrillDown:
	
			break;
        case DPMTableViewControllerContentTypeQueue:
            loaded = ([[DPMusicController sharedController] queue].count > 0);
            self.items = [[DPMusicController sharedController] queue];
            break;
		default:
			break;
	}
	
	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (self.tableContentType & DPMTableViewControllerContentTypeDrillDown || self.tableContentType & DPMTableViewControllerContentTypeQueue) {
		return @"";
	}
	
	DPMusicItemIndexSection *indexSection = [self.items objectAtIndex:section]; // IOHAVOC objectAtIndex:section]
	return indexSection.indexTitle;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
	if (self.tableContentType & DPMTableViewControllerContentTypeDrillDown || self.tableContentType & DPMTableViewControllerContentTypeQueue) {
		return nil;
	}
	return [self valueForKeyPath:@"items.indexTitle"];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	if (self.tableContentType & DPMTableViewControllerContentTypeDrillDown || self.tableContentType & DPMTableViewControllerContentTypeQueue) {
		return 0;
	}
	return index;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{	
	if (!loaded) {
		return 0;
	}
	
	if (self.tableContentType & DPMTableViewControllerContentTypeDrillDown || self.tableContentType & DPMTableViewControllerContentTypeQueue) {
		return 1;
	}
    
	return self.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if (!loaded) {
		return 0;
	}
	
	if (self.tableContentType & DPMTableViewControllerContentTypeDrillDown || self.tableContentType & DPMTableViewControllerContentTypeQueue) {
		return self.items.count;
	}
	
	DPMusicItemIndexSection *indexSection = [self.items objectAtIndex:section]; // IOHAVOC objectAtIndex:section];

	return indexSection.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }

	DPMusicItem *item;
	
	if (self.tableContentType & DPMTableViewControllerContentTypeDrillDown || self.tableContentType & DPMTableViewControllerContentTypeQueue) {
		item = [self.items objectAtIndex:indexPath.row]; // IOHAVOC objectAtIndex:[indexPath.row]];
	} else {
		DPMusicItemIndexSection *indexSection = [self.items objectAtIndex:indexPath.section]; // IOHAVOC objectAtIndex:[indexPath.section]];
		item = [indexSection.items objectAtIndex:indexPath.row];  // IOHAVOC objectAtIndex:indexPath.row]; 
	}

    if([item isKindOfClass:[DPMusicItemIndexSection class]] && self.tableContentType == DPMTableViewControllerContentTypeArtists)
    {
        DPMusicItemArtist* artist = [[(DPMusicItemIndexSection*)item items] objectAtIndex:0];
        cell.textLabel.text = artist.generalTitle;
        cell.detailTextLabel.text = artist.generalSubtitle;
    }
    else if([item isKindOfClass:[DPMusicItemIndexSection class]] && self.tableContentType == DPMTableViewControllerContentTypeAlbums)
    {
        DPMusicItemAlbum* album = [[(DPMusicItemIndexSection*)item items] objectAtIndex:0];
        cell.textLabel.text = album.generalTitle;
        cell.detailTextLabel.text = album.generalSubtitle;
        
        cell.imageView.image = [album getRepresentativeImageForSize:CGSizeMake(44, 44)];
    }
    else {
        
        cell.textLabel.text = item.generalTitle;
        cell.detailTextLabel.text = item.generalSubtitle;
    }
	
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DPMusicItemIndexSection *indexSection = [self.items objectAtIndex:indexPath.section]; // IOHAVOC objectAtIndex:indexPath.section]; 
	DPMusicItem *selectedItem = [indexSection.items objectAtIndex:indexPath.row]; // IOHAVOC objectAtIndex:indexPath.row];
	
	if (self.tableContentType == DPMTableViewControllerContentTypeSongs) {

		[[DPMusicController sharedController] addSong:(DPMusicItemSong*)selectedItem error:nil];
		[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
		
	} else if (self.tableContentType == DPMTableViewControllerContentTypeArtists) {
		DPMTableViewController *controller = [[DPMTableViewController alloc] initWithStyle:UITableViewStylePlain];
		controller.tableContentType = DPMTableViewControllerContentTypeDrillDown;

		NSArray *albums = [(DPMusicItemArtist*)selectedItem albums];
		
		controller.items = albums;
		controller.tableTitle = selectedItem.generalTitle;
		[self.navigationController pushViewController:controller animated:YES];
	} else if (self.tableContentType == DPMTableViewControllerContentTypeAlbums) {
		DPMTableViewController *controller = [[DPMTableViewController alloc] initWithStyle:UITableViewStylePlain];
		controller.tableContentType = DPMTableViewControllerContentTypeDrillDown;
		
		NSArray *songs = [(DPMusicItemAlbum*)selectedItem songs];
		
		controller.items = songs;
		controller.tableTitle = selectedItem.generalTitle;
		[self.navigationController pushViewController:controller animated:YES];
	} else if (self.tableContentType == DPMTableViewControllerContentTypeQueue) {
		
	}
}

@end
