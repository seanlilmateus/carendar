module Carendar
  class StickyHeaderDaily < NSCollectionViewFlowLayout
    def init
      super.tap do |instance|
        @separator_height = 1.0
        @separator_color = NSColor.with(red: 0.682, green:0.676, blue:0.73, alpha:0.5)
      end
    end
    attr_accessor :separator_height, :separator_color


    def self.layoutAttributesClass
      ColoredLayoutAttributes
    end


    def layoutAttributesForElementsInRect(rect)
      items = super(rect).mutableCopy
      clv = self.collectionView
      return unless clv
      content_offset = clv.contentOffset

      items += missing_sections(items)
      items.select { |item| item.representedElementKind.nil? }
           .each do |item|
              width = item.frame.size.width
              height = item.frame.size.height
              origin_y =  item.frame.origin.y - 20.0
              size = NSSize.new(width, height)
              item.frame = NSRect.new([50, origin_y - 25.0], size)
            end
      
      items.select { |item| item.representedElementKind == NSCollectionElementKindSectionHeader }
           .each do |item|
              section = item.indexPath.section
              number_of_items_in_section = clv.numberOfItemsInSection(section)
           
              first_cell_indexPath = NSIndexPath.indexPathForItem(0, inSection:section)
           
              i = [0, (number_of_items_in_section - 1)].max
              last_cell_indexPath = NSIndexPath.indexPathForItem(i, inSection:section)
           
              first_cell_attrs = self.layoutAttributesForItemAtIndexPath(first_cell_indexPath)
              last_cell_attrs = self.layoutAttributesForItemAtIndexPath(last_cell_indexPath)
           
              header_height = CGRectGetHeight(item.frame)
              origin = item.frame.origin
              pos = [
                 content_offset.y, 
                 (CGRectGetMinY(first_cell_attrs.frame) - header_height)
              ].max
            
              diff = first_cell_attrs.frame.size.height
              origin.y = [
                 pos, 
                 (CGRectGetMaxY(last_cell_attrs.frame) - header_height) - diff
              ].min + 5.0
            
              item.zIndex = 1024
              size = NSSize.new(50.0, first_cell_attrs.frame.size.height)
              item.frame = CGRect.new(origin, size)
           end
        items
    end


    def missing_sections(items)
      collection = []
      missing_sections = NSMutableIndexSet.indexSet
      categoy_item = NSCollectionElementCategoryItem
      section_header = NSCollectionElementKindSectionHeader
     
      items.select { |item| item.representedElementCategory == categoy_item }
           .each   { |item| missing_sections.addIndex(item.indexPath.section) }
         
      items.select { |item| item.representedElementKind ==  section_header }
            .each   { |item| missing_sections.removeIndex(item.indexPath.section) }
    
      operation = Proc.new do |index, _|
        indexPath = NSIndexPath.indexPathForItem(0, inSection:index)
        attributes = self.layoutAttributesForSupplementaryViewOfKind(section_header, atIndexPath:indexPath)
        if attributes && !CGSizeEqualToSize(attributes.size, CGSizeZero)
          collection.addObject(attributes)
        end
      end
      missing_sections.enumerateIndexesUsingBlock(operation)
      collection
    end


    def shouldInvalidateLayoutForBoundsChange(_)
      true
    end


    def layoutAttributesForInterItemGapBeforeIndexPath(indexPath)
      attributes = super
      return nil unless attributes
      base_frame = attributes.frame
      base_frame.size.width = self.collectionView.bounds.size.width
      attributes.frame = CGRect.new([0, NSMaxY(base_frame)], 
                                    [base_frame.size.width, separator_height])
      attributes.zIndex = 2
      attributes.color = separator_color
      attributes
    end


    def initialLayoutAttributesForAppearingDecorationElementOfKind(kind, atIndexPath:indexPath)
      attributes =  self.layoutAttributesForDecorationViewOfKind(kind, atIndexPath:indexPath)
      return attributes
    end
  end
  
end