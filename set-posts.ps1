Function Get-Layouts {
    $headerLayout = Get-Content -Path ./_layout/_header.html -Raw
    $homeLayout = Get-Content -Path ./_layout/main.html -Raw
    $footerLayout = Get-Content -Path ./_layout/_footer.html -Raw

    Return @{
        Header = $headerLayout
        Home   = $homeLayout
        Footer = $footerLayout
    }
}

Function Get-PostFrontMatter($postContent) {
    $frontMatter = [regex]::Match($postContent, "(---(?:\r?\n(?!--|\s*$).*)*)\s*((?:\r?\n(?!---).*)*\r?\n---)")
    Return $frontMatter
}

Function Set-Headings($postHtml) {
    Return $postHtml -Replace '<h(\d) id="(.*)">', {
        $level = $_.Groups[1].Value
        $id = $_.Groups[2].Value
        $class = Switch ($level) {
            '1' { 'text-4xl font-bold mb-2' }
            '2' { 'text-3xl font-bold mb-2' }
            '3' { 'text-2xl font-bold mb-2' }
            '4' { 'text-xl font-bold mb-2' }
            '5' { 'text-lg font-bold mb-2' }
            '6' { 'text-base font-bold mb-2' }
        }
        "<h$level class='$class' id='$id'>"
    }
}

Function ConvertTo-Slug {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$String
    )
    process {
        $slug = $String -replace '[^\w\s-]', '' # remove non-word characters except hyphens
        $slug = $slug -replace '\s+', '-' # replace whitespace with a single hyphen
        $slug = $slug -replace '^-+|-+$', '' # remove leading/trailing hyphens
        $slug = $slug.ToLower() # convert to lowercase
        Write-Output $slug
    }
}

Function Get-Posts {
    $markdownPosts = Get-ChildItem -Path ./posts -Filter *.md
    $posts = @()
    Foreach ($post in $markdownPosts) {
        $postContent = Get-Content -Path $post.FullName -Raw
        $frontMatter = Get-PostFrontMatter $postContent
        $frontMatterObject = $frontMatter | ConvertFrom-Yaml

        $slug = $frontMatterObject.slug ?? (ConvertTo-Slug "$($frontMatterObject.date)-$($frontMatterObject.title)")
        $body = $postContent.Replace($frontMatter.Value, "") | ConvertFrom-Markdown
        $postHtml = $layouts.Home -replace '{{header}}', $layouts.Header `
            -replace '{{title}}', $frontMatterObject.title `
            -replace '{{nav}}', (Set-Navs) `
            -replace '{{content}}', $body.Html `
            -replace '{{footer}}', $layouts.Footer

        $postHtml = Set-Headings $postHtml
        $postHtml | Out-File -FilePath ./build/$slug.html

        $posts += @{
            title   = $frontMatterObject.title
            slug    = $slug
            excerpt = $frontMatterObject.excerpt
            date    = $frontMatterObject.date
            author  = $frontMatterObject.author
            body    = $body.Html
        }
    }
    Return $posts
}

Function Set-Archive {
    $posts = Get-Posts
    $archive = @()
    $archive = @"
        <ul class="list-disc list-inside">
            $($posts | ForEach-Object { "<li><a href='$($_.slug).html'>$($_.title)</a></li>" })
        </ul>
"@
    Return $archive -join "`r`n"
}

Function Copy-ToBuild {
    $layouts = Get-Layouts
    $latestPosts = Get-Posts | ForEach-Object { @"
    <div class="bg-white rounded-lg shadow p-6">
        <img src="https://via.placeholder.com/300x200" alt="$($_.title)" class="mb-4 rounded w-full">
        <h2 class="text-2xl font-bold mb-2">$($_.title)</h2>
        <p class="text-gray-700">$($_.excerpt)</p>
            <a href="$($_.slug).html" class="mt-4 inline-block text-blue-600 hover:text-blue-800">ادامه مطلب</a>
        </div>
"@
    }

    $homeLayout = $layouts.Home -replace '{{header}}', $layouts.Header `
        -replace '{{nav}}', (Set-Navs) `
        -replace '{{title}}', 'بلاگ من' `
        -replace '{{content}}', ('<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">' + $latestPosts + '</div>') `
        -replace '{{footer}}', $layouts.Footer

    $homeLayout | Out-File -FilePath ./build/index.html

    Copy-Item -Path ./img -Destination ./build -Recurse -Force

}

Function Set-Navs {
    $navs = @(
        @{
            title = "صفحه اصلی"
            url   = "/sample"
        },
        @{
            title = "درباره ما"
            url   = "/sample/about.html"
        },
        @{
            title = "تماس با ما"
            url   = "/sample/contact.html"
        }
    )
    $navLayout = Get-Content -Path ./_layout/_nav.html -Raw
    $navLayout -replace '{{nav}}', ($navs | ForEach-Object { "<li><a href=""$($_.url)"" class=""text-gray-700 hover:text-gray-800 m-2"">$($_.title)</a></li>" })
}


Copy-ToBuild